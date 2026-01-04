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
      server = WEBrick::HTTPServer.new :Port => 3000, :DocumentRoot => @builder.target
      server.start
    end
  end
end
