

class NicoAPI

  @Mylist:
    list: (group_id, callback)->
      xhr = NicoAPI.call "/api/mylist/list", group_id: group_id, (e, data)->
        try
          callback.call null, e, JSON.parse(data), xhr if callback?.call
        catch e
          callback.call null, e, null, xhr if callback?.call

  @call: (path, params, callback)->
    NicoAPI.request "POST", "http://www.nicovideo.jp" + path, params, callback
      
  @queryEncode: (params)->
    _encode = (str)=> encodeURIComponent(str).replace( /%20/g, '+' )
    ( _encode(k) + '=' + _encode(v) for k, v of params).join '&'
  @request: (method, url, params, callback)->
    [params, callback] = [callback, params] unless callback

    query = null
    query = NicoAPI.queryEncode params if params

    if method is 'GET'
      url = url + '?' + query
      query = null

    xhr = new XMLHttpRequest

    xhr.onreadystatechange = ->
      COMPLETED = 4
      STATUS_OK = 200
      if xhr.readyState is COMPLETED and xhr.status is STATUS_OK
        callback.call null, null, xhr.responseText, xhr

    xhr.open method, url
    xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded' if method is 'POST'
    xhr.send query

    return xhr


window.NicoAPI = NicoAPI
