class HyperAlerts.Views.Subscriptions.Services.Twitter.New extends Backbone.View
  template: JST["backbone/templates/subscriptions/services/twitter/new"]

  events:
    "click .type": "showTypes"

  initialize: (options) ->
    super
    @verifyTwitterToken()

  # Render the view.
  render: ->
    @$el.html @template()

    # By default we show the search type
    @setType("timeline")

    return this

  # Verify that the user has authorized our Twitter application, or request
  # that he or she does so.
  verifyTwitterToken: ->
    unless TWITTER_ACCESS_TOKEN
      affirm
        title: "We need your help."
        body: "Twitter doesn't allow us to use their API on your behalf without
          you first giving us access. Please authenticate with Twitter to enable
          Twitter alerts."
        ok: 'Continue'
        cancel: 'Cancel'
        accept: =>
          window.location = TWITTER_AUTH_URL
        decline: =>
          @options.parent.setService "facebook"

      return false

  # Show the drop-down menu listing subscription types.
  showTypes: (e) ->
    unless @typesPopup
      @typesPopup = @createTypesPopup()
      @$el.append(@typesPopup)
    else
      @typesPopup.show()

    # Close services popup when you click outside.
    $('body').on "click", (e) =>
      if $(e.target).is '.type, .type *, .popup, .popup *'
        false
      else
        @typesPopup.hide()

  # Set the subscription type.
  #
  # type - A String describing the subscription type (either "search" or "timeline").
  setType: (type) ->
    @typesPopup.hide() if @typesPopup # Hide select types popup

    # Style type icon
    $("li", ".type").removeClass("active")
    $("li." + type, ".type").addClass("active")

    container = @$('.type_container')

    if @subView
      @subView.remove()

    # Initialise the subview for the given type
    switch type
      
      when "search"
        view = new HyperAlerts.Views.Subscriptions.Services.Twitter.Search.New
          collection : @collection
      when "timeline"
        view = new HyperAlerts.Views.Subscriptions.Services.Twitter.Timeline.New
          collection : @collection
      else
        view = null

    @subView = view
    container.append(@subView.render().el)

  # Create the DOM element for the drop-down menu to select subscription type.
  createTypesPopup: ->
    view = @
    popup = $("ul", "nav.type").clone() # Clone the ul element inside the nav.
    popup.addClass("popup")
    popup.addClass("type_select")

    # Loop through all the list items, and add a click event to them
    popup.children().each ->
      listItem = $(this)
      typeName = listItem.data("type")
      listItem.bind "click", ->
        view.setType(typeName)

    popup
