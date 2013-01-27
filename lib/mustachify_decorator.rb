module MustachifyDecorator
  extend ActiveSupport::Concern

  included do
    attr_accessor :js
    alias :js? :js
  end

  module ClassMethods

    def mustachify_attributes(*attrs)
      attrs = [attrs] unless attrs.respond_to? :each
      attrs = attrs.map(&:to_sym)

      attrs.each do |attr|
        class_eval do
          define_method attr do
            model.send(attr)
          end

          alias_method :"old_#{attr}", :"#{attr}"

          define_method attr do
            mustache_for attr do
              send(:"old_#{attr}")
            end
          end
        end
      end
    end

    def for_js_template
      new(model_class.new).tap { |d| d.js = true }
    end

  end

  # Replaces encoded double mustaches in a link with unencoded double mustaches
  def m(link)
    link.gsub(URI.encode('{{'), '{{').gsub(URI.encode('}}'), '}}')
  end

  # Meant to be called from within a method defined on the decorator itself.
  #
  # e.g.
  #
  #     class ThingDecorator < Draper::Base
  #       include MustacheDecoratorConcern
  #
  #       def foo
  #         mustache_or do
  #           "Here's your foo"
  #         end
  #       end
  #     end
  #
  #     # with an instance
  #
  #     decorator.foo #=> "Here's your foo"
  #     decorator.js = true
  #     decorator.foo #=> "{{foo}}"
  #
  def mustache_or
    method = caller.first.match(/`(.*)'/)[1]
    if js?
      "{{#{method}}}"
    else
      yield
    end
  end

  # Does basically the same thing as `mustache_or`, but is meant for when the
  # use of `caller` doesn't work (i.e., when called from within a module like
  # it is above in this file)
  def mustache_for(attr)
    if js?
      "{{#{attr}}}"
    else
      yield
    end
  end

end
