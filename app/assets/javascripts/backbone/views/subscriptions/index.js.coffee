class HyperAlerts.Views.Subscriptions.Index extends Backbone.View
  render: (types = ['facebook', 'twitter_search', 'twitter_timeline']) ->
    @clear()

    # Allow the 'types' argument to be a string, too, but convert it to an array
    # for consistency.
    unless types instanceof Array
      types = [types]

    for model in @collection.models

      if model.get('type') in types

        # Instantiate the correct view class based on the type of model
        switch model.get 'type'
          when 'facebook'
            view = new HyperAlerts.Views.Subscriptions.Services.Facebook.Show
              model: model
          when 'twitter_search'
            view = new HyperAlerts.Views.Subscriptions.Services.Twitter.Search.Show
              model: model
          when 'twitter_timeline'
            view = new HyperAlerts.Views.Subscriptions.Services.Twitter.Timeline.Show
              model: model

        if view.model.isNew()
          view.hide()
          view.show()

        @$el.append view.el

        view.render()

  clear: ->
    @$el.html ""

  refresh: ->
    @clear()
    @render()
