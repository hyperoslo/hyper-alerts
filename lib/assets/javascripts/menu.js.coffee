class window.Menu
  constructor: (options) ->
    @parent   = options.parent
    @menu     = options.menu
    @content  = options.content

    $(window).on "hashchange", =>
      @render window.location.hash

    @render window.location.hash || $(@menu + " a:first").attr "href"

  render: (hash) ->
    $(@content, @parent).hide()
    $(@content + hash, @parent).show()

    $(@menu + " a", @parent).removeClass "active"
    $(@menu + " a[href='" + hash + "']").addClass "active"
