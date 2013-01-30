class FooDecorator < Dent::Decorator
  decorates :foo

  def path
    h.foo_path(model)
  end

  def edit_path
    h.edit_foo_path(model)
  end

end
