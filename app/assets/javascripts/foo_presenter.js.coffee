window.App ||= {}
window.App.Presenters ||= {}

class App.Presenters.FooPresenter

  constructor: (attributes) ->
    @[attrName] = attrValue for attrName, attrValue of attributes

  path: ->
    "/foos/#{@id}"

  edit_path: ->
    "/foos/#{@id}/edit"

