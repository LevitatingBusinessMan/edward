module Edward
  class CLI
    def initialize
      @builder = Builder.new
    end
    
    def main
      @builder.start
      serve if ARGV.first == "serve"
      init if ARGV.first == "init"
    end
  
    def serve
      require "webrick"
      port = ARGV[1] ? ARGV[1].to_i : 3000
      @server = WEBrick::HTTPServer.new :Port => port, :DocumentRoot => @builder.target
      trap("INT") { @server.shutdown }
      listen
      puts "visit edward at http://127.0.0.1:#{@server.config[:Port]}"
      @server.start
    end
    
    def listen
      require "listen"
      Listen.to('.', ignore: /_site/) { |modified, added, removed|
        puts "rebuilding"
        @builder.start
      }.start
    end
    
    def init
      require "fileutils"
      FileUtils.mkdir_p "_include"
      FileUtils.mkdir_p "_layouts"
      File.write ".gitignore", <<~END
        _site
      END
    end
  end
end
