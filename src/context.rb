module Edward
  # Context for a template to run in
  class RenderContext
    def initialize page
      @page = page
    end

    def include file, locals = {}, &block
      include_path = "_include/" + file
      yaml, content = Page.extract_front_matter(File.read(include_path))
      options = (yaml&.dig(:options) || {}).merge(fixed_locals: "(locals:)")
      Tilt[include_path].new(options) { content }.render(self, { local: locals }, &block)
    end
  end
end
