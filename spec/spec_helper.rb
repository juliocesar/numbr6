module Numbr6
  MESSAGES = {
    :no_ident => "NOTICE AUTH :*** No identd (auth) response",
    :ping     => "PING :card.freenode.net"
  }
  
  module UsefulForSpecs
    def timesout_shortly(&block)
      begin
        Timeout.timeout(0.1) { yield block } rescue nil
      rescue TimeoutError
        # do nothing
      end
    end
    
  end
  
  class FauxIRCServer
    def initialize(port = 9999)
      @socket = TCPServer.new '0.0.0.0', port
    end
    
    def emulate(response)
      Thread.new do
        client = @socket.accept
        client.write MESSAGES[response] + "\r\n"
        client.readline rescue nil # not important
        client.close
      end
    end
    
    def kill!
      @socket.close
      @worker.kill!
    end
  end  
end

Spec::Runner.configure do |config|
  config.include Numbr6::UsefulForSpecs
end

