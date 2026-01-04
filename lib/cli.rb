module Edward
  class CLI
    def initialize
      @builder = Builder.new
    end
    
    def main
      @builder.start
      serve if ARGV.include? "serve"
    end
  
    def serve
      require "webrick"
      server = WEBrick::HTTPServer.new :Port => 3001, :DocumentRoot => @builder.target
      server.start
    end
    
    def init
      require "fileutils"
      FileUtils.mkdir_p "_include"
      FileUtils.mkdir_p "_layouts"
      File.write(".gitignore", "_site")
    end
  end
end
