window.App ||= {}
window.App.Models ||= {}

class App.Models.Foo extends Backbone.Model

  presenterName: 'FooPresenter'

  urlRoot: '/foos'

  presenter: ->
    new App.Presenters[@presenterName](@attributes)
