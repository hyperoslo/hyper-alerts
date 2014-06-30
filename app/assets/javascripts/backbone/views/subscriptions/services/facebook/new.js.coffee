delay = ( ->
  timer = 0

  (callback, ms) ->
    clearTimeout timer
    timer = setTimeout callback, ms
)()

currentHighlight = -1

class HyperAlerts.Views.Subscriptions.Services.Facebook.New extends Backbone.View
  template: JST["backbone/templates/subscriptions/services/facebook/new"]

  events:
    "submit form": "submitForm"

  render: ->
    @$el.html @template()

    view = @
    input = @$('.terms')

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
            view.outputGraphResult( searchPhrase )
          , 500
        else
          $('.suggestions').hide()

    return this

  submitForm: (e) ->
    e.preventDefault()
    return false

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

  validateDirectPageURL: (url) ->
    facebookRootURL = 'facebook.com/'
    lookForRoot = url.indexOf facebookRootURL
    searchPageId = url.substr lookForRoot + facebookRootURL.length

    if url.indexOf("http") > -1 and url.indexOf(facebookRootURL) > -1 and searchPageId.length > 2

      return {
        pageId : searchPageId
        status : true
      }

    else
      return {
        pageId : ''
        status : false
      }
    
  outputGraphResult: ( searchPhrase ) ->
    view = @
    
    directURLCheck = view.validateDirectPageURL searchPhrase
    if directURLCheck.status

      directURLResult = view.validateDirectPageURL searchPhrase
      searchPageId = directURLResult.pageId

      facebookURLs = [
        'https://graph.facebook.com/' + searchPageId + '?access_token=' + FACEBOOK_ACCESS_TOKEN
      ]

      directURL = true

    else
      facebookURLs = [
        'https://graph.facebook.com/search?q=' + searchPhrase + '&access_token=' + FACEBOOK_ACCESS_TOKEN + '&type=page&callback=?'
        'https://graph.facebook.com/search?q=' + searchPhrase + '&access_token=' + FACEBOOK_ACCESS_TOKEN + '&type=place&callback=?'
      ]

    jxhr = []
    result = 0

    $.each facebookURLs, (i, url) ->
      jxhr.push $.getJSON url, (json) ->
        result = json
        if directURL then result = { data: [ json ] }

    $.when.apply($, jxhr).done =>
      currentHighlight = -1

      for data, i in result.data
        if i > 8 then break
        view.add data
  
  add: (data) ->
    notValid = true
    if data.category then notValid = false
    
    page = new HyperAlerts.Models.Facebook.Page
      facebook_id: data.id
      name: data.name
      category: data.category
    
    searchResult = new HyperAlerts.Views.Services.Facebook.Pages.SearchResult
      model : page
      notValid : notValid
    
    searchResult.render()
    searchResult.on "select", (page) =>
      subscription = @collection.create
        page : page.toJSON()
        type: 'facebook'
        frequency: "0 10 * * *"
        scope: ["posts", "comments"]
        polled: true
        pushed: false
    
      $('.suggestions').hide()
      $('input.add_page_input').val ''
    
    $('.suggestions').append searchResult.el
