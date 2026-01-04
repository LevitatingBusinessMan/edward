require "fileutils"
require "yaml"
require "tilt"

module Edward
  # Builds a website
  class Builder
    
    attr_reader :target
    
    def initialize
      @target = "_site"
    end
    
    def start
      FileUtils.rm_r @target if File.exist? @target
      FileUtils.mkdir_p @target

      Dir.glob("**/*") do |path|
        visit_file path if File.file?(path) &&
          !path.start_with?("_") &&
          !["Gemfile", "Gemfile.lock"].include?(path)
      end
    end
    
    def visit_file path
      if Convertible.convertible?(path)
        convertible = Edward::Convertible.new(path)
        puts "converting #{convertible.path} => #{convertible.dirname}/#{convertible.new_name}"
        FileUtils.mkdir_p "#{@target}/#{convertible.dirname}"
        File.write("#{@target}/#{convertible.new_path}", convertible.convert)
      else
        copy_plain path
      end
    end
    
    # simply copy the file
    def copy_plain path
      FileUtils.mkdir_p "#{@target}/#{File.dirname path}"
      FileUtils.cp path, "#{@target}/#{path}"
    end
    
  end
end
