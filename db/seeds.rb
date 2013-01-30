if Foo.count == 0
  Foo.create!(name: 'Foo')
  Foo.create!(name: 'Bar')
  Foo.create!(name: 'Baz')
  Foo.create!(name: nil)
end
