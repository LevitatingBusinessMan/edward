module Edward
  # Context for a template to run in
  class RenderContext
    def initialize page
      @page = page
    end

    def include file, locals = {}
      include_path = "_include/" + file
      yaml, content = Page.extract_front_matter(File.read(include_path))
      if File.exist? include_path
        Tilt[include_path].new(nil, nil, yaml&.dig(:options)){ content }.render(self, { local: locals }) { yield }
      else
        raise "#{file} not found in _include"
      end
    end
  end
end
