class HyperAlerts.Views.Alert extends Backbone.View
  template: JST["backbone/templates/alert"]

  className: "alert"

  events:
    "click .button" : "dismiss"

  render: ->
    @$el.html @template
      title: @options.title
      body: @options.body
      ok: @options.ok

    return this

  dismiss: ->
    @$el.remove()
