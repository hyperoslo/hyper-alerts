class HyperAlerts.Views.Issue extends Backbone.View
  template: JST["backbone/templates/issue"]

  className: "issue"

  render: ->
    @$el.html @template
      msg: @options.msg
      url : @options.url
      urlDesc : @options.urlDesc

    return this
