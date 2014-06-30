HyperAlerts.Models.Subscription = Backbone.Model.extend
  urlRoot: "/subscriptions"
  defaults:
    preset: 'daily'

HyperAlerts.Collections.SubscriptionsCollection = Backbone.Collection.extend
  model: HyperAlerts.Models.Subscription
  url: "/subscriptions.json"

  all: ->
    # If we have a unfiltered collection reset to that.
    if @unfiltered
      @reset @unfiltered.models
