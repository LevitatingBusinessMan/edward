require "fileutils"
require "yaml"
require "tilt"

module Edward
  # Builds a website
  class Builder
    
    attr_reader :target
    
    def initialize
      @target = "_site"
      FileUtils.rm_r @target if File.exist? @target
      FileUtils.mkdir_p @target
    end
    
    def start
      Dir.glob("**/*") do |path|
        visit_file path if File.file?(path) &&
          !path.start_with?("_") &&
          !["Gemfile", "Gemfile.lock"].include?(path)
      end
    end
    
    def visit_file path
      content = File.read(path)
      if content.start_with? "---"
        convertible = Edward::Convertible.new(path)
        puts "converting #{convertible.path} => #{convertible.dirname}/#{convertible.new_name}"
        FileUtils.mkdir_p "#{@target}/#{convertible.dirname}"
        File.write("#{@target}/#{convertible.dirname}/#{convertible.new_name}", convertible.convert)
      else
        copy_plain path
      end
    end
    
    # simply copy the file
    def copy_plain path
      FileUtils.mkdir_p "#{@target}/#{File.dirname path}"
      FileUtils.cp path, "#{@target}/#{path}"
    end
    
    # def convert path, yaml, content
    #   if (template = Tilt[path])
    #     template = template.new { content }
    #     converted = template.render(self)
    #     if (layout = get_layout(yaml[:layout]))
    #       layout.render(RenderContext.new, yaml[:locals]) { converted }
    #     else
    #       converted
    #     end
    #   else
    #     raise "no engine mapped for #{path}"
    #   end
    # end
    
    # def get_layout name
    #   if File.exist? "_layouts/#{name}.slim"
    #     return Tilt.new("_layouts/#{name}.slim")
    #   end
    # end
    
  end
end
