class HyperAlerts.Views.Confirm extends Backbone.View
  template: JST["backbone/templates/confirm"]

  className: "confirm"

  events:
    "click .ok" : "accept"
    "click .cancel" : "decline"

  render: ->
    @$el.html @template
      title: @options.title
      body: @options.body
      ok: @options.ok
      cancel: @options.cancel

    return this

  accept: ->
    @$el.hide()
    @options.accept()

  decline: ->
    @$el.remove()
    @options.decline()
