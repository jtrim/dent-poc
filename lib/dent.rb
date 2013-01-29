module Dent
  class << self
    attr_accessor :dentable_templates
  end
  @dentable_templates = []

  def self.comment_marker_for(filename)
    lang_comments = {
      'slim' => '/',
      'erb'  => '<%#',
      'haml' => '-#'
    }
    match = filename.match Regexp.new("(#{lang_comments.keys.join("|")})$")
    match && lang_comments[match[1]]
  end

  def self.bootstrap
    Dir['app/views/**/_*'].each do |filename|
      if comment_marker = comment_marker_for(filename)
        file_comments = File.new(filename).lines.take_while { |l| l.strip =~ Regexp.new("^#{comment_marker}") }
        Dent.dentable_templates << filename if file_comments.grep(/dentify|dentable/).present?
      end
    end
  end

  def self.render
    view_lookup_context = ActionView::LookupContext.new(Dir['app/views'])
    views = ActionView::Base.new(view_lookup_context)
    script_template = "<script type='text/mustache' id='%s'>%s</script>"
    dentable_templates.map do |filename|
      match = filename.match(/_([^\.]+)/)
      if match && entity_name = match[1].to_sym
        short_filename = filename.match(/([^\/]+)\/_([^\/\.]+)/)[1..-1].join('/')
        decorator_class = "#{entity_name}_decorator".classify.constantize
        script_template % ["#{entity_name}-template", views.render(short_filename, entity_name => decorator_class.for_js_template)]
      end
    end.join("").html_safe
  end

end
