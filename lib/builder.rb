require "fileutils"
require "yaml"
require "tilt"

module Edward
  # Builds a website
  class Builder
    
    attr_reader :target
    
    def initialize
      @target = "_site"
      @gitignore = File.read(".gitignore").lines rescue []
    end
    
    def start
      FileUtils.rm_r @target if File.exist? @target
      FileUtils.mkdir_p @target

      Dir.glob("**/*") do |path|
        visit_file path if visit_file?(path)
      end
    end
    
    def visit_file? path
      File.file?(path) &&
      !path.start_with?("_") &&
      !["Gemfile", "Gemfile.lock"].include?(path) &&
      !@gitignore.include?(path)
    end

    def visit_file path
      if Page.page?(path)
        page = Edward::Page.new(path)
        puts "converting #{page.path} => #{page.dirname}/#{page.new_name}"
        FileUtils.mkdir_p "#{@target}/#{page.dirname}"
        File.write("#{@target}/#{page.new_path}", page.convert)
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
