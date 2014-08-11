
#= require ./lib/request.coffee

class NicoSession
  @URL:
    login: 'https://secure.nicovideo.jp/secure/login_form'
    loginForm: 'https://secure.nicovideo.jp/secure/login?site=niconico'
    logout: 'https://secure.nicovideo.jp/secure/logout'
    mypage: 'http://www.nicovideo.jp/my/top'
    
  constructor: ->
  isLogin: (callback)->
    self = @
    request.get NicoSession.URL.mypage, (err, body, xhr)->
      state = if xhr.responseURL.indexOf(NicoSession.URL.login) < 0
        true
      else
        false
      callback.apply self, [err, state]
            
  doLogin: (email, password, callback)->
    self = @
    
    request.post NicoSession.URL.loginForm, {mail_tel: email, password: password}, (err, body, xhr)->
      self.isLogin (err, state)->
        callback.apply self, [err, state]

  doLogout: (callback)->
    self = @
    request.get NicoSession.URL.logout, (err, body, xhr)->
      callback.apply self, [err] if callback
      
window.NicoSession = NicoSession
  
