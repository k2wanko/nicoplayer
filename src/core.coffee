do ($=jQuery)->

  window.appWindow = chrome.app.window.current()
    
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

  nicoapi = window._nicoapi = 
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
        
    idParse: (url)->
      return "" unless url
      url.match(/watch\/([a-z]+[0-9]+)/)[1]
  
  session = window.session = new NicoSession

      
      
  $ ->

    $toolbar = $ "#toolbar"
    $v_ctl = $ "#video-ctl"

    for _$ in [$toolbar, $v_ctl]
      _$
      .on 'mouseenter', (-> @css "opacity", "1" ).bind(_$)
      .on 'mouseleave', (-> @css "opacity", "0" ).bind(_$)

    $("#close_btn").click ->
      appWindow.close()

    $("#alwaysOnTop").click ->
      className = "glyphicon-ok"
      _$ = $(@).find("span")
      appWindow.setAlwaysOnTop flag = !appWindow.isAlwaysOnTop()
      if flag then _$.addClass(className) else _$.removeClass(className)

    player = window._player = new CommentPlayer "#player"
    player.$.volume = 0.15
    player.$.autoplay = false
    $(window).resize ->
      player.requestResize()
      
    $("#play_btn").click ->
      if player.paused() then player.play() else player.pause()

    chrome.commands.onCommand.addListener (cmd)->
      if cmd is 'play-pause'
        if player.paused() then player.play() else player.pause()

    player.onplay = ->
      document.querySelector('#play_btn span').className = "glyphicon glyphicon-pause"
      
    player.onpause = ->
      document.querySelector('#play_btn span').className = "glyphicon glyphicon-play"

    player.onpaused = ->
      console.log 'paused'
           
    currentUrl = ""

    play = window._play = (id)->
      if id.match(/^http/)
        id = nicoapi.idParse id
      url = "http://www.nicovideo.jp/watch/#{id}"
      request.get url, (err)->
        return showError err.message if err
        time = 1000 * 60 * 10
        sessionLooper = (_url)->
          new ->
            @url = _url
            console.log 'looper check', @url is url, @url, url
            if @url is url
              request.get url, (err)->
                return showError err.message if err
              setTimeout sessionLooper.bind(null, @url), time
        setTimeout sessionLooper.bind(null, url), time
        nicoapi.getflv id, (err, data)->
          return showError err.message if err
          document.querySelector("#player").src = data.url
          nicoapi.getcomment data, (err, data, xhr)->
            return showError err.message if err
            data = data.sort (a, b)-> a.vpos - b.vpos
            player.play() #debug

    randomPlay = ->
      NicoAPI.Mylist.list "45448706", (err, data)->
        return showError err if err

        # sort by new order
        data.mylistitem = data.mylistitem.sort (a, b)->
          a.create_time < b.create_time
          
        ids = for item in data.mylistitem
          item.item_data.video_id
        
        i = Math.floor(Math.random() * data.mylistitem.length)

        play ids[i]

    
    session.isLogin (err, state)->
      return showError err if err
      return requestLogin() unless state
      randomPlay()
      
