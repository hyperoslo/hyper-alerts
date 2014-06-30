###
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/hyper_alerts
//= require facebook
//= require menu
//= require jquery.number
//= require_tree .
###


issue = (data) ->
  issue = new HyperAlerts.Views.Issue
    msg : data.msg
    url : data.url
    urlDesc : data.urlDesc

  issue.render()

  $('#header').after issue.el

window.issue = issue

warn = (data) ->
  warn = new HyperAlerts.Views.Alert
    title : data.title
    body : data.body
    ok : data.ok

  warn.render()

  $('body').prepend warn.el

window.warn = warn

affirm = (data) ->
  affirm = new HyperAlerts.Views.Confirm
    title : data.title
    body : data.body
    ok : data.ok
    cancel : data.cancel
    accept: data.accept
    decline: data.decline

  affirm.render()
  $('body').prepend affirm.el

window.affirm = affirm
