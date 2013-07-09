
$(document).keydown (e) =>

  if e.keyCode == 37
    @Router.set_video(Session.get('previous_stub'), 'left')
  else if e.keyCode == 39
    @Router.set_video(Session.get('next_stub'), 'right')
  else if e.keyCode == 13
    window.location = Session.get('current_vid').link if Session.get('current_vid')


get_stub = (vid) ->
  vid.link.replace("http://www.ted.com/talks/", "").replace(".html", "")

Meteor.startup ->

  Backbone.history.start({pushState: true})

  Session.set('loading', true)

  Deps.autorun ->

    if !Session.get('vids')

      Meteor.http.get("http://pipes.yahoo.com/pipes/pipe.run?_id=c6b9f27dbbdfed8e30e5dc0a9b445bda&_render=json", (err, result) ->
        Session.set('vids', result.data.value.items)
        Session.set('vid_count', result.data.count)
      )

    else if Session.get('current_stub') #find vid corresponding to stub

      vids = Session.get('vids')
      _.each(vids, (vid, index) ->

        stub = get_stub(vid)
        if stub == Session.get('current_stub')

          Session.set('current_vid', vid)

          if vids[index-1]
            Session.set('previous_stub', get_stub(vids[index-1]))
          else
            Session.set('previous_stub', get_stub(vids[vids.length-1]))
          if vids[index+1]
            Session.set('next_stub', get_stub(vids[index+1]))
          else
            Session.set('next_stub', get_stub(vids[0]))

          false
      )

      Session.set('loading', false)
      


###
Router
###

tRouter = Backbone.Router.extend

  routes:
    "": "reroute"
    ":vid_stub": "load_vid"

  reroute: ->
    window.location = "/jinha_lee_a_tool_that_lets_you_touch_pixels"

  load_vid: (vid_stub) ->

    Session.set('current_stub', vid_stub)

  set_video: (stub, dir) ->
    
    if dir == 'left'
      $('#vid-wrap').addClass('anim-left')
    else if dir == 'right'
      $('#vid-wrap').addClass('anim-right')
   
    #this.navigate(stub, true)
    $('#vid-wrap').one('webkitAnimationEnd oanimationend msAnimationEnd animationend', (e) =>
      this.navigate("/#{stub}", true)
    )

@Router = new tRouter


###
Templates
###

Template.vid.loading = ->
  Session.get('loading')

Template.vid.vid = ->
  Session.get('current_vid')

Template.vid.events

  'click #vid-wrap': ->
    window.location = Session.get('current_vid').link

Template.nav.events

  'click a.nav': (e) =>
    e.preventDefault()
    elem = $(e.srcElement)
    if elem.attr('id') == 'left'
      @Router.set_video(Session.get('previous_stub'), $(e.srcElement).attr('id'))
    else if elem.attr('id') == 'right'
      @Router.set_video(Session.get('next_stub'), $(e.srcElement).attr('id'))

###
Helpers
###

Template.vid.get_info = (vid, info) ->
  if info == "title"
    if vid['itunes:subtitle'].length > 60
      "#{vid['itunes:subtitle'].substring(0,55)}..."
    else
      vid['itunes:subtitle']
  else if info == "image"
    vid["itunes:image"]["url"]
  else if info == "des"
    "#{vid.description.substring(0,180)}..."




