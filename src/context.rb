module Edward
  # Context for a template to run in
  class RenderContext
    def initialize page
      @page = page
    end

    def include file, locals = {}, &block
      include_path = "_include/" + file
      # yaml in includes is currently ignored
      _yaml, content = Page.extract_front_matter(File.read(include_path))
      Tilt[include_path].new(@page[:options]&.merge(fixed_locals: "(locals:)")){ content }.render(self, { local: locals }, &block)
    end
  end
end
