decorators_path = Rails.root.join("app", "decorators")
Dir.new(decorators_path).grep(/_decorator\.rb$/).each do |filename|
  require decorators_path.join(filename)
  decorator_class = filename.gsub(/.rb$/, '').classify.constantize
  decorator_class.finalize
end
