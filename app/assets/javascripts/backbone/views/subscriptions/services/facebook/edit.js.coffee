#= require ../../edit
class HyperAlerts.Views.Subscriptions.Services.Facebook.Edit extends HyperAlerts.Views.Subscriptions.Edit
  template: JST["backbone/templates/subscriptions/services/facebook/edit"]

  events: _.extend
    "click .tab_navigation .scopes": "showScope"
    "click input[name=messages]": "promptPermissionsForPrivateMessages"
  , HyperAlerts.Views.Subscriptions.Edit.prototype.events

  # Require the user to grant "manage_pages" permission.
  #
  # options - An options object:
  #           success: A function to call upon granting the permission.
  #           error:   A function to call upon refusing to grant the permission.
  requireManagePagesPermission: (options) ->
    Facebook.permissions.list success: (permissions) ->
      if "manage_pages" in permissions and "read_page_mailboxes" in permissions
        options.success() if options.success
      else
        affirm
          title: "We need your help!"
          body: "You need to let us to manage your pages to do this. But don't fret, we're not evil. Promise."
          ok: "Sure, no problem!"
          cancel: "No way!"
          accept: ->
            Facebook.permissions.request
              permissions: ["manage_pages", "read_page_mailboxes"]
              success: ->
                options.success() if options.success
              error: ->
                options.error() if options.error
          decline: ->
            options.error() if options.error

  # Require the user to be the administrator of the given page.
  #
  # options - An options object:
  #           success: A function to call if the user is an administrator.
  #           error:   A function to call if the user isn't an administrator.
  requireAdministrator: (options) ->
    @requireManagePagesPermission
      success: =>
        Facebook.pages.isAdministrator @model.attributes.page.facebook_id,
          success: ->
            options.success() if options.success
          error: ->
            warn
              title: "Bad news"
              body: "Sorry friend, but Facebook won't let us do that for pages you're not an administrator of."
              ok: "Aw, shoot!"

            options.error() if options.error
      error: ->
        options.error() if options.error

  promptPermissionsForPrivateMessages: (event) ->
    checkbox = $(event.target)

    event.preventDefault()

    if checkbox.is ':checked'
      @requireAdministrator
        success: ->
          checkbox.prop 'checked', true

  showScope: ->
    @tab "scopes"

    @$('input[name=posts]').on 'change', (event) =>
      if $(event.target).is ':checked'
        @$('input[name=comments]').prop 'disabled', false
      else
        @$('input[name=comments]').prop 'disabled', true
        @$('input[name=comments]').prop 'checked', false

  save: ->
    scope = []

    if @$('input[name=posts]').is ':checked'
      scope.push 'posts'

    if @$('input[name=comments]').is ':checked'
      scope.push 'comments'

    if @$('input[name=messages]').is ':checked'
      scope.push 'messages'

    scope.push @$("select[name=filter]").find(":selected").val()

    @model.set scope: scope

    super
