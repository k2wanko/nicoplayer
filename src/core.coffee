do ($=jQuery)->

  #= require ./lib/request.coffee
    
  save = (item, callback)-> chrome.storage.local.set item, callback
  get = (key, callback)-> chrome.storage.local.get key, callback
    
  encode = (str)-> btoa(btoa(encodeURIComponent(str)))
  decode = (str)-> decodeURIComponent(atob(atob(str)))

  window.showError = (err = "")->
    dialog = document.querySelector('dialog#errorDialog')
    $dialog = $(dialog)
    $dialog.css 'opacity', 1
    dialog.show()
    dialog.querySelector('p').innerText = err
    setTimeout ->
      $dialog.animate
        'opacity': 0
        complete: -> dialog.close()
      , "slow"
    , 3000

  requestLogin = ->
    loginDialog = document.querySelector('dialog#login')
    loginDialog.showModal()
    $("#loginForm").submit ->
      setTimeout ->
        $email = $ "#mail_tel"
        $password = $ "#password"
        if $email.val() and $password.val()
          session.doLogin $email.val(), $password.val(), (err, state)->
            return showError err.message if err
            return showError "Login failure"  unless state
            loginDialog.close()
      , 0
      return false

  nicoapi =
    decode: (str)->
      res = {}
      for item in  str.split '&'
        data = item.split '='
        res[data[0]] = decodeURIComponent data[1]
      res
    getthumbinfo: (id, callback)->
      url = "http://ext.nicovideo.jp/api/getthumbinfo/" + id
      request.get url, (err, body, xhr)->
        return callback(err) if err
        callback.apply null, [null, xhr.responseXML, xhr]
    getflv: (id, callback)->
      url = "http://flapi.nicovideo.jp/api/getflv/" + id
      request.get url, (err, body, xhr)->
        return callback(err) if err
        data =  nicoapi.decode body
        callback.apply null, [null, data, xhr]
    getcomment: (data, callback)->
      url = data.ms.replace('api', 'api.json') + "thread"
      request.get url,
        version: '20090904'
        thread: data.thread_id
        res_from: -100
      , (err, body, xhr)->
        return callback err if err

        comments = []
        for res in JSON.parse body
          comments.push res.chat if res.chat
        callback null, comments, xhr
        
        
  
  session = window.session = new NicoSession
      
  $ ->

    player = window._player = new CommentPlayer "#player"
    player.$.volume = 0.15
    currentSrc = ""

    play = window._play = (id)->
      url = "http://www.nicovideo.jp/watch/#{id}"
      request.get url, (err)->
        return showError err.message if err
        time = 1000 * 60 * 10
        sessionLooper = ->
          request.get url, (err)->
            return showError err.message if err
          setTimeout sessionLooper, time if document.querySelector("#player").src is currentSrc
        setTimeout sessionLooper, time
        nicoapi.getflv id, (err, data)->
          return showError err.message if err
          document.querySelector("#player").src = currentSrc = data.url
          nicoapi.getcomment data, (err, data, xhr)->
            return showError err.message if err
            console.log data

    
    session.isLogin (err, state)->
      return showError err if err
      return requestLogin() unless state
      id = "sm17822068" #"1407469585" #"1407398611"
      play id
      
