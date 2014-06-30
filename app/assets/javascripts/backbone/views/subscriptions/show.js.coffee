class HyperAlerts.Views.Subscriptions.Show extends Backbone.View
  render: ->
    @$el.html @template @model.attributes

    element = @$ ".schedule_info"

    if @model.get "frequency"
      element.html prettyCron.toString @model.get 'frequency'

    if @model.isNew()
      # This is both a hack and a feature. If we just call "edit" without a timeout
      # it won't appear to do anything (probably because it's being rendered multiple times
      # or something, and the last time it's not new anymore). On the other hand, it's kind-of
      # neat to do it this way because the user gets the impression that we just clicked the button
      # for him/her.
      setTimeout ( => @edit() ), 1000

    return this

  events: ->
    "click .actions .edit" : "edit"
    "click .delete" : =>
      affirm {
        title: 'Are you sure?'
        body: 'Deleting a subscription causes the loss of all your settings. Do you wish to continue?'
        ok: 'Continue'
        cancel: 'Cancel'
        accept: => @delete()
      }

      return false

  show: ->
    @$el.animate
      'top' : '0'
      'opacity' : 1
    , 350

  hide: ->
    @$el.css 'top', '-130px'
    @$el.css 'opacity', 0

  edit: ->
    view = new @editView
      model : @model
      showView: @

    view.render()
    @$el.html view.el

  delete: ->
    @model.destroy
      success: (model, response) ->
        # Even though we don't do anything, we need to have this success handler.
