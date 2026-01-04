module Edward
  # represents a file that may be converted
  class Convertible
    YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze

    attr_reader :path, :layout
    
    def initialize path, locals = {}, &block
      @path = path
      @locals = locals || {}
      @block = block
      content = File.read(path)
      @yaml, @content = Convertible.extract_front_matter(content)
      @template = Tilt[path].new { @content }
      @layout = get_layout(@yaml&.dig(:layout))
    end

    def render
      @template.render(Edward::RenderContext.new(self), { local: @locals }, &@block)
    end

    def convert
      if @layout
        @layout.convert
      else
        render
      end
    end
    
    def self.extract_front_matter content
      if content =~ YAML_FRONT_MATTER_REGEXP
        yaml = YAML.safe_load(Regexp.last_match(1), symbolize_names: true)
        content = Regexp.last_match.post_match
        [yaml, content]
      else
        [nil, content]
      end
    end
    
    def get_layout name
      if File.exist? "_layouts/#{name}.slim"
        Convertible.new("_layouts/#{name}.slim", @yaml&.dig(:locals)) { render }
      end
    end
    
    # the name of the new file
    def new_name
      "#{File.basename(@path, ".*")}.html"
    end
    
    def dirname
      File.dirname(@path)
    end
    
  end
end
