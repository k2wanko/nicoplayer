
do =>
  request = module.exports = 
    get: (url, params, callback)->
      [callback, params] = [params, callback] unless callback
      query = if params then request._encode(params) else null
      url = url + '?' + query if query
        
      xhr = new XMLHttpRequest
      xhr.onreadystatechange = do -> request._onreadystatechange xhr, callback

      xhr.open 'GET', url
    
      xhr.send()

    post: (url, params, callback)->  
      [callback, params] = [params, callback] unless callback
      query = if params then request._encode(params) else null
        
      xhr = new XMLHttpRequest
      xhr.onreadystatechange = do -> request._onreadystatechange xhr, callback
      
      xhr.open 'POST', url
      xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
      xhr.send query

    _onreadystatechange: (xhr, callback)->
      ->
        COMPLETED = 4
        STATUS_OK = 200

        if xhr.readyState is COMPLETED and xhr.status is STATUS_OK
          callback.call null, null, xhr.responseText, xhr
      
    _encode: (params)->
      encode = (str)=> encodeURIComponent(str).replace( /%20/g, '+' )
      ( encode(k) + '=' + encode(v) for k, v of params).join '&'
