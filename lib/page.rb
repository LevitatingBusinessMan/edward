require "deep_merge"

module Edward
  # represents a file that may be converted
  class Page
    YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze

    attr_reader :path, :layout, :yaml

    def initialize path, locals = {}
      @path = path
      @locals = locals || {}
      content = File.read(path)
      @yaml, @content = Page.extract_front_matter(content)
      @block = nil
      @template = Tilt[path].new(nil, nil, self[:options]) { @content }
      add_layout(self[:layout]) if self[:layout]
      # layout notes:
      # prob best course of action is to grab the layout frontmatter
      # merge it with the page's frontmatter, and then add the template to a stack
    end
    
    # check if a file starts with yaml doc and can be mapped by tilt
    def self.page? path
      !Tilt.templates_for(path).empty? && YAML_FRONT_MATTER_REGEXP.match(File.read(path))
    end

    def render
      @template.render(Edward::RenderContext.new(self), nil, &@block)
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
    
    # wrap this page in a layout
    def add_layout name
      layout_path = "_layouts/#{name}.slim"
      yaml, content = Page.extract_front_matter(File.read(layout_path))
      @yaml = yaml.deep_merge!(@yaml, knockout_prefix: "--")
      inner_template = @template
      inner_block = @block
      @block = proc { inner_template.render(Edward::RenderContext.new(self), nil, &inner_block) }
      @template = Tilt[layout_path].new(nil, nil, self[:options]) { content }
    end
    
    def name
      File.basename(@path)
    end
    
    # the name of the new file
    def new_name
      File.basename(@path, ".*")
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
