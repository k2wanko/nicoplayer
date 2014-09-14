
do ->
  request = require './request'
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
        
    idParse: (url)->
      return "" unless url
      url.match(/watch\/([a-z]+[0-9]+)/)[1]

  module.exports = nicoapi if module?

