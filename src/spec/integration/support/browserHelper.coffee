zombie      = new require 'zombie'

exports.selectorLoaded = (w) ->
  console.log "waiting #{@selectorSearched}"
  w.document.querySelector @selectorSearched

exports.waitSelector = (selector, cb) ->
  @selectorSearched = selector
  @wait @selectorLoaded, cb

exports.pressButtonWait = (selector, cb) ->
  @waitSelector selector, => @pressButton selector, cb

exports.newBrowser = (browser) ->
  storage = browser?.saveStorage()
  browser = new zombie.Browser()
  browser.loadStorage storage if storage?
  browser.selectorSearched = exports.selectorSearched
  browser.waitSelector = exports.waitSelector
  browser.pressButtonWait = exports.pressButtonWait
  browser