module Edward
  # Context for a template to run in
  class RenderContext
    def initialize page
      @page = page
    end

    def include file, locals = {}
      include_path = "_include/" + file
      if File.exist? include_path
        Tilt.new(include_path).render(self, { local: locals }) { yield }
      else
        raise "#{file} not found in _include"
      end
    end
  end
end
