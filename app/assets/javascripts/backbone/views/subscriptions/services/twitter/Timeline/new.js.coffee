delay = ( ->
  timer = 0

  (callback, ms) ->
    clearTimeout timer
    timer = setTimeout callback, ms
)()

currentHighlight = -1

class HyperAlerts.Views.Subscriptions.Services.Twitter.Timeline.New extends Backbone.View
  template: JST["backbone/templates/subscriptions/services/twitter/timeline/new"]

  events:
    "submit form": "submitForm"
    "keypress": "showSearchResult"

  render: ->
    @$el.html @template()
    return this

  submitForm: (e) ->
    e.preventDefault()
    return false

  showSearchResult: ->
    view = @
    input = $('input.terms')

    input.on 'keyup', (e) =>
      e.stopImmediatePropagation()
      searchPhrase = $(e.target).val()

      if e.keyCode in [40, 38, 13]
        view.keyNavigation(e)
      else
        if searchPhrase.length > 2
          @$('.suggestions .suggestion').remove()

          $('.suggestions').show()
          $('body:not(.suggestions)').one "click", ->
            $('.suggestions').hide()

          delay ->
            view.outputSearchResult( searchPhrase )
          , 500
        else
          $('.suggestions').hide()

  keyNavigation: (e) ->
    $hlight = $('.highlight')
    $div = $('.suggestion')
    numberOfResults = $('.suggestion').length

    if currentHighlight >= numberOfResults-1 then currentHighlight = -1
    if currentHighlight < -numberOfResults then currentHighlight = numberOfResults

    if e.keyCode is 40
      currentHighlight++
      $hlight.removeClass 'highlight'
      $div.eq(currentHighlight).addClass 'highlight'
      $div.eq(currentHighlight).focus()

    else if e.keyCode is 38
      currentHighlight--
      $hlight.removeClass 'highlight'
      $div.eq(currentHighlight).addClass 'highlight'

    else if e.keyCode is 13
      $div.eq(currentHighlight).trigger 'click'

  outputSearchResult: (searchPhrase) ->
    view = @

    twitterURLs = [
      '/services/twitter/users/search?q=' + searchPhrase + '&count=10'
    ]

    jxhr = []
    result = 0

    $.each twitterURLs, (i, url) ->
      jxhr.push $.getJSON url, (json) ->
        result = json

    $.when.apply($, jxhr).done =>
      currentHighlight = -1

      for data, i in result
        if i > 8 then break
        view.add data

  add: (data) ->
    timeline = new HyperAlerts.Models.Twitter.Timeline
      twitter_id : data.id
      name : data.name
      screen_name : data.screen_name
      picture_url : data.profile_image_url_https

    searchResult = new HyperAlerts.Views.Services.Twitter.Timelines.SearchResult
      model : timeline

    searchResult.render()
    searchResult.on "select", (page) =>
      subscription = @collection.create
        timeline : timeline.toJSON()
        type: 'twitter_timeline'
        terms: data.terms
        frequency: "0 10 * * *"
        polled: true
        pushed: false

      $('.suggestions').hide()
      $('input.add_page_input').val ''

    $('.suggestions').append searchResult.el
