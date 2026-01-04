require "tilt"
require "low_type"
require "yaml"
require "slim"

module Edward
  YAML_FRONT_MATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m.freeze

  def self.main
    path = ARGV.first
    handle_file path
    #template = p Tilt.new(ARGV.first)
    #ctx = RenderContext.new
    #puts ctx.render path
  end
  
  def self.handle_file path
    content = File.read(path)
    if content =~ YAML_FRONT_MATTER_REGEXP
      yaml = YAML.load(Regexp.last_match(1), symbolize_names: true)
      content = Regexp.last_match.post_match
      puts convert(path, yaml, content)
    else
      puts "plain"
    end
  end
  
  def self.convert path, yaml, content
    if (template = Tilt[path])
      template = template.new { content }
      converted = template.render(self)
      if (layout = get_layout(yaml[:layout]))
        layout.render(RenderContext.new, yaml[:locals]) { converted }
      else
        converted
      end
    else
      raise "no engine mapped for #{path}"
    end
  end
  
  def self.get_layout name
    if File.exist? "_layouts/#{name}.slim"
      return Tilt.new("_layouts/#{name}.slim")
    end
  end
  
  class RenderContext
    # searches in _include for relative paths
    # or accepts an absolute
    def include file, options = {}
      include_path = "_include/" + file
      if File.exist? include_path
        Tilt.new(include_path).render(self, options) { yield }
      else
        raise "#{file} not found in _include"
      end
    end

    # def render path, options={}, &block
    #   docs = YAML.load_stream(File.read(path), symbolize_names: true)
    #   case docs
    #   in [Hash => front_matter, String => content]
    #   in [String => content]
    #     front_matter = {}
    #   else
    #     raise "unexpected yaml layout"
    #   end

    #   puts content

    #   if (template = Tilt[path])
    #     template = template.new { content }
    #     template.render(self, front_matter[:locals], &block)
    #   else
    #     content
    #   end
    # end
  end
  
end

Edward.main

# module Edward
#   def render
    
#   end
# end
