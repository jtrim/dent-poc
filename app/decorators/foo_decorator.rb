class FooDecorator < Draper::Base
  include MustachifyDecorator
  mustachify_attributes :name

  decorates :foo


  def if(param_name, &block)
    block_output_buffer = eval('@output_buffer', block.binding)
    length_before_block = block_output_buffer.to_s.length

    result = if js?
      block.call
      rendered_segment = block_output_buffer.to_s[length_before_block..-1]
      ("{{##{param_name}}}" + rendered_segment + "{{/#{param_name}}}").html_safe
    else
      if model.send(param_name).present?
        block.call
        block_output_buffer.to_s[length_before_block..-1]
      end
    end
    block_output_buffer.replace(block_output_buffer.to_s[0...length_before_block]).html_safe
    result
  end

  def unless(param_name, &block)
    block_output_buffer = eval('@output_buffer', block.binding)
    length_before_block = block_output_buffer.to_s.length

    result = if js?
      block.call
      rendered_segment = block_output_buffer.to_s[length_before_block..-1]
      ("{{^#{param_name}}}" + rendered_segment + "{{/#{param_name}}}").html_safe
    else
      unless model.send(param_name).present?
        block.call
        block_output_buffer.to_s[length_before_block..-1].html_safe
      end
    end
    block_output_buffer.replace(block_output_buffer.to_s[0...length_before_block])
    result
  end

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
