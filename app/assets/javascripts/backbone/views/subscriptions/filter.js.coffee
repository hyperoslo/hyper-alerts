class HyperAlerts.Views.Subscriptions.Filter extends Backbone.View
  template: JST["backbone/templates/subscriptions/filter"]

  events:
    "click #all" : "filterAll"
    "click #facebook" : "filterFacebook"
    "click #twitter" : "filterTwitter"

  render: ->
    @$el.append @template
    return this

  filterAll: (e) ->
    e.preventDefault()

    @options.view.render()

    $('.filter_link a').removeClass 'active'
    $('.filter_link #all').addClass 'active'

  filterFacebook: (e) ->
    e.preventDefault()

    @options.view.render 'facebook'

    $('.filter_link a').removeClass 'active'
    $('.filter_link #facebook').addClass 'active'

  filterTwitter: (e) ->
    e.preventDefault()

    @options.view.render ['twitter_search', 'twitter_timeline']

    $('.filter_link a').removeClass 'active'
    $('.filter_link #twitter').addClass 'active'
