# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require jquery
#= require jquery_ujs
#= require underscore
#= require raphael
#= require g.raphael
#= require g.line

$ ->

  element = $("body.statistics")

  if element.length

    setInterval ->

      $.ajax
        url: "/statistics/summary.json"
        success: (categories) ->
          for category, statistics of categories
            container = $(".category[data-name=#{category}]")

            for label, value of statistics
              container.find(".value[data-name=#{label}]").text value

    , 1000
