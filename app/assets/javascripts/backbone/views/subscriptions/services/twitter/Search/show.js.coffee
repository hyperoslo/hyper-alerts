#= require ../../../show
class HyperAlerts.Views.Subscriptions.Services.Twitter.Search.Show extends HyperAlerts.Views.Subscriptions.Show
  className: "twitter subscription"

  template: JST["backbone/templates/subscriptions/services/twitter/search/show"]

  editView: HyperAlerts.Views.Subscriptions.Services.Twitter.Search.Edit
