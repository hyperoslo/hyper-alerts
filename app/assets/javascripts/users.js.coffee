$ ->
  new Menu
    parent: "#settings"
    menu: ".menu"
    content: ".settings"

  $('#request-manage-pages-permissions').on 'click', ->
    Facebook.permissions.request
      permissions: "manage_pages"
      success: ->
        window.location.reload()

$.ajax "/users/me/time_zone_difference",
  data:
    time_zone_name: jstz.determine().name()
  success: (difference) ->
    difference = parseInt difference

    if difference < 0
      difference = -difference
      ahead = true
    else
      ahead = false

    if difference
      issue
        msg: "You seem to be #{difference} " + (if difference == 1 then "hour" else "hours") + " " + (if ahead then "ahead of" else "behind") + " your selected time zone."
        url: "/users/me/edit"
        urlDesc: "Change it?"
