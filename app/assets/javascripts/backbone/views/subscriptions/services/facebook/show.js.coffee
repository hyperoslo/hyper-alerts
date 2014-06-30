#= require ../../show
class HyperAlerts.Views.Subscriptions.Services.Facebook.Show extends HyperAlerts.Views.Subscriptions.Show
  className: "facebook subscription"

  template: JST["backbone/templates/subscriptions/services/facebook/show"]

  editView: HyperAlerts.Views.Subscriptions.Services.Facebook.Edit
  
  initialize: ->
    @model.on "change", =>
      @render()
      $('span.page_likes').number true, 0, '.', ' '

    $('span.page_likes').number true, 0, '.', ' '
