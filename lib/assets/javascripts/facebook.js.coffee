@Facebook =

  pages:

    # Verify whether user is an administrator for the given page.
    #
    # id      - A string or integer identifying the page.
    # options - An options object:
    #           success - A function to call if the user is an administrator.
    #           error   - A function to call if the user is not an administrator.
    isAdministrator: (id, options) ->
      FB.api '/me/accounts', (response) =>
        page = _.find response.data, (page) =>
          return page.id == id

        if page
          options.success()
        else
          options.error()

  permissions:

    # Request permission(s).
    #
    # options - An options object:
    #           permissions - An array of strings describing permissions.
    #           success     - A function to call if the user grants permissions.
    #           error       - A function to call if the user declines to grant permissions.
    request: (options) ->
      requested_permissions = options.permissions

      unless _.isArray requested_permissions
        requested_permissions = [requested_permissions]

      FB.login (response) ->
        Facebook.permissions.list success: (given_permissions) ->
          success = _.every requested_permissions, (requested_permission) ->
            _.contains given_permissions, requested_permission

          if success
            options.success() if options.success
          else
            options.error() if options.error
      , scope: requested_permissions.join ","

    # List permissions.
    #
    # options - An options object:
    #           success - A function to call if the user grants permissions. Receives an
    #                     array of strings describing permissions.
    list: (options) ->
      FB.api "/me/permissions", (response) ->
        # Facebook's API returns an array 'data' that only has a single item for some reason.
        permissions = response.data[0]

        array = []

        for permission, granted of permissions
          array.push permission if granted

        options.success array
