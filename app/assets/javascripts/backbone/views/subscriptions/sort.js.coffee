class HyperAlerts.Views.Subscriptions.Sort extends Backbone.View
  template: JST["backbone/templates/subscriptions/sort"]

  events:
    "click #alphabetical" : "sortAlphabetical"
    "click #date_created" : "sortDateCreated"
    "click #date_modified" : "sortDateModified"
    "click #type" : "sortType"

  initialize: ->
    @sortDateCreated()
    return this

  render: ->
    @$el.append @template
    return this

  sortAlphabetical: (e) ->
    if e then e.preventDefault()

    @collection.comparator = (model) ->
      switch model.get('type')
        when 'facebook'
          model.get('page').name
        when 'twitter_search'
          model.get('search').terms
        when 'twitter_timeline'
          model.get('timeline').screen_name

    @collection.sort()

    $('.sort_link a').removeClass 'active'
    $('.sort_link #alphabetical').addClass 'active'

    return this

  sortDateCreated: (e) ->
    if e then e.preventDefault()

    @collection.comparator = (model) =>
      createdAt = model.get 'created_at'

      if createdAt
        -Date.parse createdAt
      else
        -Date.now()

    @collection.sort()

    @$('.sort_link a').removeClass 'active'
    @$('.sort_link #date_created').addClass 'active'

    return this

  sortDateModified: (e) ->
    if e then e.preventDefault()

    @collection.comparator = (model) ->
      -Date.parse model.get 'updated_at'

    @collection.sort()

    $('.sort_link a').removeClass 'active'
    $('.sort_link #date_modified').addClass 'active'

    return this

  sortType: (e) ->
    if e then e.preventDefault()

    @collection.comparator = (model) ->
      model.get 'type'

    @collection.sort()

    $('.sort_link a').removeClass 'active'
    $('.sort_link #type').addClass 'active'

    return this
