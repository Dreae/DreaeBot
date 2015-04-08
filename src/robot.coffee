xmpp = require 'node-xmpp'
fs = require 'fs'
crypto = require 'crypto'
request = require 'request'
Message = require './message'

class Robot
  constructor: (jid, password, @room, @nick) ->
    @client = new xmpp.Client {
      'jid': jid,
      'password': password
    }
    @joined = 0
    @bob_cache = {}
    @hear_list = []
    @resp_list = []
    @mention_re = new RegExp("#{@nick}: (.*)", 'i')

    @client.on 'stanza', (stanza) =>
      if Date.now() - @joined < 1000
        return
      if stanza.attrs.from == @room + '/' + @nick
        return

      if stanza.is('iq') and stanza.attrs.type == 'get'
        cid = stanza.children[0].attrs.cid
        if not (cid of @bob_cache)
          return

        fs.readFile '/tmp/' + crypto.createHash('sha1').update(cid).digest('hex'), (err, data) =>
          elem = new xmpp.Element 'iq', {
            id: stanza.attrs.id,
            to: stanza.attrs.from,
            type: 'result'
          }
          elem.c('data', {cid: cid, 'max-age': 86400, type: @bob_cache[cid], xmlns: 'urn:xmpp:bob'}).t(data.toString('base64'))
          @client.send(elem)
      else if stanza.is('message') and stanza.attrs.type != 'error'
        msg = new Message(@, stanza)
        for trigger in @hear_list
          match = msg.body.match(trigger[0])
          if match
            msg.match = match
            trigger[1] msg
            return

        mentioned = msg.body.match(@mention_re)
        if mentioned
          mentioned = mentioned[1].trim()
          for trigger in @resp_list
            match = mentioned.match(trigger[0])
            if match
              msg.match = match
              trigger[1] msg
              return

    @client.on 'online', () =>
      console.log 'online'

      @client.send new xmpp.Element('presence')
      @client.send new xmpp.Element('presence', {to: @room + '/' + @nick}).c('x', {xmlns: 'http://jabber.org/protocol/muc'})
      @joined = Date.now()

    @client.on 'error', (error) =>
      console.error error.toString()

    process.on 'sigint', () =>
      @client.send('</stream:stream>')
      process.exit()

    @load_scripts()

  send: (body) =>
    elem = new xmpp.Element 'message', {
      to: @room,
      type: 'groupchat'
    }
    elem.c('body').t(body)
    @client.send elem

  send_img: (imgUrl) =>
    hash = crypto.createHash('sha1').update(imgUrl).digest('hex')
    cid = "sha1+#{hash}@bob.xmpp.org"
    stream = fs.createWriteStream('/tmp/' + crypto.createHash('sha1').update(cid).digest('hex'))
    request(imgUrl, (error, response, body) =>
      if !error and response.statusCode == 200
        @bob_cache[cid] = response.headers['content-type']
        elem = new xmpp.Element 'message', {
          to: @room,
          type: 'groupchat'
        }
        elem.c('html', 'http://jabber.org/protocol/xhtml-im').c('body', 'http://www.w3.org/1999/xhtml').c("img src='cid:#{cid}'");
        @client.send(elem)
    ).pipe(stream)

  send_img_html: (imgUrl) =>
    elem = new xmpp.Element 'message', {
      to: @room,
      type: 'groupchat'
    }
    elem.c('html', 'http://jabber.org/protocol/xhtml-im').c('body', 'http://www.w3.org/1999/xhtml').c("img src='#{imgUrl}'");
    @client.send(elem)

  hear: (regex, action) =>
    @hear_list.push [regex, action]

  respond: (regex, action) =>
    @resp_list.push [regex, action]

  load_scripts: () =>
    scripts = require '../scripts/scripts.json'
    for script in scripts
      bootstrap = require "../scripts/#{script}"
      bootstrap(@)

module.exports = Robot
