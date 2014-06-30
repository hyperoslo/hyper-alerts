class HyperAlerts.Views.Subscriptions.New extends Backbone.View
  template: JST["backbone/templates/subscriptions/new"]

  events:
    "click .service": "showServices"

  render: ->
    @$el.html @template()

    # Default to facebook service
    @setService("facebook")

    return this

  showServices: (e) ->
    unless @servicesPopup
      # Add the popup to the DOM
      @servicesPopup = @createServicesPopup()
      @$el.append(@servicesPopup)
    else
      @servicesPopup.show()

    # Close services popup when you click outside.
    $('body').on "click", (e) =>
      if $(e.target).is '.service, .service *, .popup .popup *'
        false
      else
        @servicesPopup.hide()

  # Setter for service
  setService: (service) ->
    @servicesPopup.hide() if @servicesPopup # Hide select services popup

    # Style service icon
    $("li", ".service").removeClass("active")
    $("li." + service, ".service").addClass("active")

    container = @$('.service_container')

    if @subView
      @subView.remove()

    # Initialise the subview for the given service
    switch service
      when "facebook"
        view = new HyperAlerts.Views.Subscriptions.Services.Facebook.New
          collection : @collection
          parent: this
      when "twitter"
        view = new HyperAlerts.Views.Subscriptions.Services.Twitter.New
          collection : @collection
          parent: this
      else
        view = null

    @subView = view
    container.append(@subView.render().el)

  createServicesPopup: ->
    view = @
    popup = $("ul", "nav.service").clone() # Clone the ul element inside the nav.
    popup.addClass("popup")
    popup.addClass("service_select")

    # Loop through all the list items, and add a click event to them
    popup.children().each ->
      listItem = $(this)
      serviceName = listItem.data("service")
      listItem.bind "click", ->
        view.setService(serviceName)

    popup
