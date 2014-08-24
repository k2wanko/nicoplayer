
css = (element, styles)->
  element.style[k] = v for k, v of styles

gcd = (a, b) ->
  if (a == b) then a else  gcd(Math.abs(a - b), if (a > b) then b else a)

class CommentPlayer

  ratio:
    width: 16
    height: 9
    
  push: (comment, options)->
    self = @
    comment = new CommentPlayer.Comment self, comment
    css comment.$,
      'left': "100%"
      #'background': 'rgba(200, 200, 200, .5)' # debug
    @comments.push comment
    @$commentArea.insertBefore comment.$, null
    css comment.$,
      'top': "#{comment.$.offsetHeight * (@comments.length-1)}px"
    comment.start()
      
    return comment

  pushAll: (comments)->
    @push c for c in comments

  remove: (comment)->
    @$commentArea.removeChild comment.$
    @comments.splice (@comments.indexOf(comment)), 1

  requestResize: ->
    $ = @$cover
    w = $.offsetWidth
    h = $.offsetHeight
    
    if w > h
      w = h / @ratio.height * @ratio.width
      if w > $.offsetWidth
        w = $.offsetWidth
        h = w / @ratio.width * @ratio.height
    else
      h = w / @ratio.width * @ratio.height
      if w > $.offsetHeight
        h = $.offsetHeight
        w = h / @ratio.height * @ratio.width

    css @$commentArea,
      width: "#{w}px"
      height: "#{h}px"

  # video control
  play: ->
    @$.play()

  pause: ->
    @$.pause()

  paused: ->
    @$.paused

  replay: ->
    @seek 0
    @play()

  seek: (time)->
    @$.currentTime = time if typeof time is "number"
    @$.currentTime

  onpause: null
          
  constructor: (selector, options)->
    return new CommentPlayer(selector, options) unless @ instanceof CommentPlayer

    self = @

    @comments = []

    defaults =
      header: ""

    unless options
      @options = defaults
    else
      @options = {}
      @options[k] = options[k] if options[k] for k, v of defaults

    @$ = if typeof selector is 'string'
      document.querySelector selector
    else if selector?.nodeName
      selector

    @$ = document.createElement 'video' unless @$
    
    @$.addEventListener 'loadeddata', ->
      res =  gcd self.$.videoWidth, self.$.videoHeight
      self.ratio.width = self.$.videoWidth/res
      self.ratio.height = self.$.videoHeight/res
      self.requestResize()

    @$.addEventListener 'play', ->
      self.onplay.call self if self.onplay?.call

    @$.onpause = -> self.onpause.call self if self.onpause?.call
      
    css @$,
      width: '95%'
      height: '95%'
      position: 'absolute'
      top: 0
      left: 0
      right: 0
      bottom: 0
      margin: 'auto'

    # controls hide
    @$.controls = false

    @$cover = document.createElement 'div'

    css @$cover,
      width: '100%'
      height: '100%'
      position: 'relative'
      margin: 0
      padding: 0
      
    @$cover.className = 'cp-cover'

    @$.parentNode.replaceChild @$cover, @$
    @$cover.insertBefore @$, null

    @$commentArea = document.createElement 'div'

    @$commentArea.className = 'comment-area'

    css @$commentArea,
      position: 'absolute'
      top: '0px'
      left: '0px'
      right: '0px'
      bottom: '0px'
      margin: 'auto'
      overflow: 'hidden'
      #'background': 'rgba(200, 0, 200, .5)' # debug

    @$cover.insertBefore @$commentArea, null
    @requestResize()
    
    #tick = 1000 / 60
    # _loop = ->
    #   for comment in self.comments
    #     comment.onFrame.call(comment, self) if comment?.onFrame?
    #   setTimeout _loop, tick
    # setTimeout _loop, tick
    
class CommentPlayer.Comment

  start: ->
    setTimeout (self)->
      console.log self
      css self.$,
        'transition': 'left 6s linear'
        'left': "-100%"
      setTimeout (self)->
        self.player.remove comments
      , 4000, self
    , 0, @
        
  constructor: (player, comment)->
    new Comment(player, text, options) unless @ instanceof CommentPlayer.Comment

    @player = player

    @$ = document.createElement 'span'

    @content = comment.content
    @$.innerText = @content
    @vpos = comment.vpos
    
    css @$,
      color: '#FFF'
      'font-size': '24px'
      'text-shadow': '1px 1px .1px #000'
      'white-space': 'nowrap'
      #display: 'inline-block'
      #display: 'block'
      top: '0px'
      position: 'absolute'
      #float: 'left'

    @$.onload = =>
      console.log 'onload', @
    
window.CommentPlayer = CommentPlayer
