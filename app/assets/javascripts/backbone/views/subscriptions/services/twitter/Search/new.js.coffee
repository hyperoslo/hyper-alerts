class HyperAlerts.Views.Subscriptions.Services.Twitter.Search.New extends Backbone.View
  template: JST["backbone/templates/subscriptions/services/twitter/search/new"]

  events:
    "submit form": "submit"

  render: ->
    @$el.html @template()
    return this

  submit: (event) ->
    terms = @$("input[name=terms]").val()

    if terms
      @add terms: terms
    else
      warn
        title: "Not so fast, friend!"
        body: "You should probably enter a search term. Trust us on this one."
        ok: "Right!"

    event.preventDefault()

  add: (data) ->
    search = new HyperAlerts.Models.Twitter.Search
      terms: data.terms

    subscription = @collection.create
      search: search.toJSON()
      type: 'twitter_search'
      frequency: "0 10 * * *"
      polled: true
      pushed: false

