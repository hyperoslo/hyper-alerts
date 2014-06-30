$ ->

  if USER_SIGNED_IN and USER_EMAIL is ''
    issue
      msg: 'You need to set an e-mail address in order to receive alerts.'
      url: '/users/me/edit'
      urlDesc: 'Set it now!'

  if $('#subscriptions').length > 0
      subscriptions = new HyperAlerts.Collections.SubscriptionsCollection()

      subscriptions.fetch
        success: (subscriptions) ->
          index = new HyperAlerts.Views.Subscriptions.Index
            el: $(".list", "#subscriptions")
            collection: subscriptions

          subscriptions.on 'add', ->
            subscriptions.sort()
            index.refresh()

          subscriptions.on 'destroy', ->
            index.refresh()

          subscriptions.on 'error', ->
            warn
              title: 'Oh no!'
              body: "This wasn't supposed to happen. We're on the case."
              ok: 'Aw, man!'

          index.render()

          subscriptions.on 'reset', ->
            index.refresh()

          subscriptions.on "sort", ->
            index.refresh()

          sortView = new HyperAlerts.Views.Subscriptions.Sort
            el: $('.menu', '#subscriptions')
            collection: subscriptions
            view: index

          filterView = new HyperAlerts.Views.Subscriptions.Filter
            el: $('.menu', '#subscriptions')
            collection: subscriptions
            view: index

          sortView.render()
          filterView.render()

      $( ->
        addView = new HyperAlerts.Views.Subscriptions.New
          el: $('.form', '#new_subscription')
          collection: subscriptions

        addView.render()
      )
