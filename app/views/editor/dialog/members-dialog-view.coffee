BaseDialogView = require './base-dialog-view'
#template = require './templates/members-dialog'
module.exports = class MembersDialogView extends BaseDialogView
  content:
    title: 'Add a collaborator'
    submit: 'Send invite'
  
  render: ->
    super
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @canvasesRef = Chaplin.mediator.firebase.child('canvases')

    @$('.modal-body').html('
      <div class="input-group" style="margin: 0 auto; width: 200px;">
        <span class="input-group-addon">@</span>
        <input type="text" class="form-control" placeholder="username" required>
      </div>')
    @delegate 'focus', 'input', @clear_messages
  
  submit: =>
    _username = @$('.modal-body input').val()
    if !_username?
      @$('.modal-body').prepend('<div class="alert alert-warning">Please enter a username.</div>')
      return false
    
    @profilesRef.child(_username).on "value", (snapshot) =>
      console.log snapshot.val()
      if snapshot.val()?
        if snapshot.val().handle isnt Chaplin.mediator.current_user.get('profile_id')
          @canvasesRef.child(@model.get('id') + '/members/' + snapshot.val().user_id).set
            user_id: snapshot.val().user_id
            role: 'editor'
            date_joined: new Date().getTime()
            profile_id: snapshot.val().handle
          @profilesRef.child(snapshot.val().handle + '/canvases/canvas_' + @model.get('id')).set id: @model.get('id')
          super
        else
          @$('.modal-body').prepend('<div class="alert alert-danger">You are already here, allegedly.</div>')
      else
        @$('.modal-body').prepend('<div class="alert alert-danger">Sorry, that user does not exist.</div>')
  
  clear_messages: =>
    @$('div.alert').remove()