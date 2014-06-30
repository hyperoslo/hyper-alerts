class HyperAlerts.Views.Services.Facebook.Pages.SearchResult extends Backbone.View
  template: JST["backbone/templates/services/facebook/pages/search_result"]

  className: "facebook suggestion"

  events:
    "click" : "select"

  render: ->
    @$el.html @template @model.toJSON()

  select: ->
    @trigger 'select', @model
