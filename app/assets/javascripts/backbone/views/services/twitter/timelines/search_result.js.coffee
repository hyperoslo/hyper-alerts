class HyperAlerts.Views.Services.Twitter.Timelines.SearchResult extends Backbone.View
  template: JST["backbone/templates/services/twitter/timelines/search_result"]

  className: "twitter suggestion"

  events:
    "click" : "select"

  render: ->
    @$el.html @template @model.toJSON()
    return this

  select: ->
    @trigger 'select', @model
