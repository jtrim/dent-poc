class FooDecorator < Dent::Decorator
  decorates :foo

  def path
    mustache_or do
      h.foo_path(model)
    end
  end

  def edit_path
    mustache_or do
      h.edit_foo_path(model)
    end
  end

end
