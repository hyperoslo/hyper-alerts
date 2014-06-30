#= require ../../../show
class HyperAlerts.Views.Subscriptions.Services.Twitter.Timeline.Show extends HyperAlerts.Views.Subscriptions.Show
  className: "twitter subscription"

  template: JST["backbone/templates/subscriptions/services/twitter/timeline/show"]

  editView: HyperAlerts.Views.Subscriptions.Services.Twitter.Timeline.Edit
