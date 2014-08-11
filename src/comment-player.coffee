
css = (element, styles)->
  element.style[k] = v for k, v of styles

class CommentPlayer

  push: (comment, options)->
    comment = if typeof comment is 'string'
      new CommentPlayer.Comment comment
    else if comment instanceof CommentPlayer.Comment
      comment
    else if typeof comment is 'object'
      new CommentPlayer.Comment comment.content, comment
                  
    #@comments.push comment
    #@$commentArea.insertBefore comment.$, null
    css comment.$,
      'margin-left': "#{@$commentArea.offsetWidth - comment.$.offsetWidth}px"
      'background': 'rgba(200, 200, 200, .5)'
    return comment

  pushAll: (comments)->
    @push c for c in comments

  remove: (comment)->
    @$commentArea.removeChild comment.$
    @comments.splice (@comments.indexOf(comment)), 1
      
  constructor: (selector, options)->
    return new CommentPlayer(selector, options) unless @ instanceof CommentPlayer

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

    @$commentArea = document.createElement 'div'

    @$commentArea.className = 'comment-area'

    css @$commentArea, 
      width: @$.offsetWidth + 'px'
      height: @$.offsetHeight + 'px'
      position: 'absolute'
      top: '0px'
      left: '0px'
      overflow: 'hidden'

    @$.parentNode.replaceChild @$cover, @$
    @$cover.insertBefore @$, null
    @$cover.insertBefore @$commentArea, null
    
    self = @

    tick = 1000 / 60
    _loop = ->
      for comment in self.comments
        comment.onFrame.call(comment, self) if comment?.onFrame?
      setTimeout _loop, tick
    setTimeout _loop, tick
    
class CommentPlayer.Comment

  speed: 1
    
  #onFrame: (player)->
  #  x = parseInt @$.style['margin-left'].slice 0, @$.style['margin-left'].indexOf('px')
  #  css @$,
  #    'margin-left': "#{@$.offsetLeft-@speed}px"
  #  if @$.offsetLeft < (@$.offsetWidth*-1)
  #    player.remove @
  #  #console.log @$.parentNode
      
  constructor: (text, options)->
    new Comment(text, options) unless @ instanceof CommentPlayer.Comment

    @$ = document.createElement 'span'
    
    @$.innerText = text if typeof text is 'string'
    @vpos = options.vpos
    
    css @$,
      color: '#FFF'
      'font-size': '24px'
      'text-shadow': '1px 1px .1px #000'
      #padding: '5px'
      #display: 'inline-block'
      #display: 'block'
      top: '0px'
      position: 'absolute'
      #float: 'left'

    @$.onload = =>
      console.log 'onload', @
    
window.CommentPlayer = CommentPlayer
