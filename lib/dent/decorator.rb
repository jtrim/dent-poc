module Dent

  class Decorator < Draper::Base
    extend ActiveSupport::DescendantsTracker

    attr_accessor :js
    alias :js? :js

    def self.finalize
      mustachify_attributes *model_class.attribute_names
      mustachify_instance_methods
    end

    def self.mustachify_instance_methods
      decorator_methods = (instance_methods - superclass.instance_methods)
      unique_instance_method_names = decorator_methods.map(&:to_s).reject do |method_name|
        model_class.attribute_names.map(&:to_s).include?(method_name.gsub(/^old_/, '')) || \
          method_name == model_class.name.underscore
      end

      unique_instance_method_names.each do |method_name|
        class_eval do
          alias_method :"old_#{method_name}", :"#{method_name}"

          define_method method_name do
            mustache_for method_name do
              send(:"old_#{method_name}")
            end
          end
        end
      end
    end

    def self.mustachify_attributes(*attrs)
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

    def self.for_js_template
      new(model_class.new).tap { |d| d.js = true }
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

    def render_section_if(param_name, block)
      block_output_buffer = eval('@output_buffer', block.binding)
      length_before_block = block_output_buffer.to_s.length

      result = if js?
        block.call
        rendered_segment = block_output_buffer.to_s[length_before_block..-1]
        ("{{##{param_name}}}" + rendered_segment + "{{/#{param_name}}}").html_safe
      else
        if yield
          block.call
          block_output_buffer.to_s[length_before_block..-1]
        end
      end
      block_output_buffer.replace(block_output_buffer.to_s[0...length_before_block]).html_safe
      result
    end

    def section(param_name, &block)
      render_section_if do
        model.send(param_name, rendered_segment).present?
      end
    end
    alias :if :section

    def inverted_section(param_name, &block)
      render_section_if do
        !(model.send(param_name, rendered_segment).present?)
      end
    end
    alias :unless :inverted_section

  end

end
