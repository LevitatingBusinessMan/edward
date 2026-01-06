module Edward
  # represents a file that may be converted
  class Page
    YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze

    attr_reader :path, :layout, :yaml

    def initialize path, locals = {}, &block
      @path = path
      @locals = locals || {}
      @block = block
      content = File.read(path)
      @yaml, @content = Page.extract_front_matter(content)
      @template = Tilt[path].new(nil, nil, @yaml&.dig(:options)) { @content }
      @layout = get_layout(@yaml&.dig(:layout))
      # layout notes:
      # prob best course of action is to grab the layout frontmatter
      # merge it with the page's frontmatter, and then add the template to a stack
    end
    
    # check if a file starts with yaml doc and can be mapped by tilt
    def self.page? path
      !Tilt.templates_for(path).empty? && YAML_FRONT_MATTER_REGEXP.match(File.read(path))
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
        yaml = YAML.safe_load(Regexp.last_match(1), symbolize_names: true, permitted_classes: [Symbol])
        content = Regexp.last_match.post_match
        [yaml, content]
      else
        [nil, content]
      end
    end
    
    def get_layout name
      if File.exist? "_layouts/#{name}.slim"
        Page.new("_layouts/#{name}.slim", @yaml&.dig(:locals)) { render }
      end
    end
    
    # the name of the new file
    def new_name
      "#{File.basename(@path, ".*")}"
    end
    
    def dirname
      File.dirname(@path)
    end
    
    def new_path
      "#{dirname}/#{new_name}"
    end
    
    def tag? tag
      @yaml&.dig(:tags)&.include? tag
    end

    def [](*keys)
      @yaml&.dig(*keys)
    end
    
  end
end
