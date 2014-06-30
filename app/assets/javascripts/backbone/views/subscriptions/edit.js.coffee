class HyperAlerts.Views.Subscriptions.Edit extends Backbone.View
  initialize: ->
    @showView = @options.showView

  events:
    "click .verify": "save"
    "click .cancel": "cancel"

  render: ->
    @$el.html @template @model.toJSON()
    @selectOption @model.get 'preset'

    @$('.presets').on 'change', =>
      @selectOption @$('.presets').val()

    @showSchedule()

  selectOption: (element) ->
    if element in ['custom', 'weekly']
      @$('.edit_schedule_custom').show()
    else
      @$('.edit_schedule_custom').hide()

    if element is 'daily'
      @$('.frequency_daily_time, .at').show()
      @$('.form select').addClass 'daily'
    else
      @$('.frequency_daily_time, .at').hide()
      @$('.form select').removeClass 'daily'

    @$('.presets').val element

  showSchedule: ->
    frequency = @model.get 'frequency'
    preset = @model.get 'preset'

    pad = (num, size) ->
      s = "00#{num}"
      s.substr s.length-size

    if preset in ['custom', 'weekly', 'daily']
      splitFrequency = frequency.split " "
      frequencyDay = splitFrequency[4]
      frequencyHour = pad splitFrequency[1], 2
      frequencyMin = pad splitFrequency[0], 2

      @$el.find('.frequency_custom_day').val frequencyDay
      @$el.find('.frequency_custom_time, .frequency_daily_time').val "#{frequencyHour}:#{frequencyMin}"

  cancel: ->
    view = @showView.render()
    view.$(".edit_schedule_feedback.discarded").show().delay(2000).fadeOut()

  proceed: ->
    view = @showView.render()
    view.$(".edit_schedule_feedback.saved").show().delay(2000).fadeOut()

  validateTime: (customTime) ->
    components = customTime.split ':'
    customHour = parseInt components[0]
    customMin = parseInt components[1]

    if customMin < 0 or customMin > 59 or isNaN customMin
      warn {
        title: 'Validation error'
        body: 'You must choose a minute between 0 and 60!'
        ok: 'try again'
      }

      false
    else if customHour < 0 or customHour > 23 or isNaN customHour
      warn {
        title: 'Validation error'
        body: 'You must choose an hour between 0 and 23!'
        ok: 'try again'
      }
    else
      components

  save: ->
    preset = @$el.find('.presets').val()
    okToSave = false

    switch preset
      when 'weekly'
        customDay = @$el.find('.frequency_custom_day').val()
        customTime = @$el.find('.frequency_custom_time').val()
        components = @validateTime customTime

        if components isnt false
          customHour = parseInt components[0]
          customMin = parseInt components[1]

          @model.set
            preset: preset
            frequency: "#{customMin} #{customHour} * * #{customDay}"
            pushed: false
            polled: true

          @model.save()

          @proceed()
      when 'daily'
        dailyTime = @$el.find('.frequency_daily_time').val()
        components = @validateTime dailyTime

        if components isnt false
          dailyHour = parseInt components[0]
          dailyMin = parseInt components[1]

          @model.set
            preset: preset
            frequency: "#{dailyMin} #{dailyHour} * * *"
            pushed: false
            polled: true

          @model.save()

          @proceed()
      when 'monthly'
        @model.set
          preset: preset
          frequency: "0 0 1 * *"
          pushed: false
          polled: true

        @model.save()

        @proceed()
      when 'hourly'
        @model.set
          preset: preset
          frequency: "0 * * * *"
          pushed: false
          polled: true

        @model.save()

        @proceed()
      when 'every 10 minutes'
        @model.set
          preset: preset
          frequency: "*/10 * * * *"
          pushed: false
          polled: true

        @model.save()

        @proceed()
      when 'real-time'
        Facebook.permissions.list success: (permissions) =>

          # TODO: Reduce code duplication.
          if 'manage_pages' in permissions
            FB.api '/me/accounts', (response) =>
              page = _.find response.data, (page) =>
                return page.id == @model.attributes.page.facebook_id

              if page
                @model.set
                  preset: preset
                  frequency: "*/10 * * * *"
                  pushed: true
                  polled: true

                @model.save()

                @proceed()
              else
                warn
                  title: "Bad news"
                  body: "Sorry friend, but Facebook will only let us alert you instantly for pages you're an administrator of."
                  ok: "Aw, shoot!"
          else
            affirm
              title: "We need your help!"
              body: "Facebook says you have to authorize us to manage your pages if you want alerts instantly. But don't fret, we're not evil. Promise."
              ok: "Sure, no problem!"
              cancel: "No way!"
              accept: =>
                Facebook.permissions.request
                  permissions: "manage_pages"
                  success: =>
                    FB.api '/me/accounts', (response) =>
                      page = _.find response.data, (page) =>
                        return page.id == @model.attributes.page.facebook_id

                      if page
                        @model.set
                          preset: preset
                          frequency: "*/10 * * * *"
                          pushed: true
                          polled: true

                        @proceed()
                      else
                        warn
                          title: "Bad news"
                          body: "Sorry friend, but Facebook will only let us alert you instantly for pages you're an administrator of."
                          ok: "Aw, shoot!"
