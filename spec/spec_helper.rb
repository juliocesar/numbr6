module Numbr6
  MESSAGES = [
    :no_ident => "NOTICE AUTH :*** Checking ident",
    :ping     => nil
  ]
  
  class FauxIRCServer
    def initialize(port = 9999)
      @socket = TCPServer.new '0.0.0.0', port
    end
    
    def emulate(response)
      Thread.new do
        client = @socket.accept
        puts "accepted #{client.inspect}"
        puts "got: #{client.readline}"
        client.write MESSAGES[response] + "\r\n"
        client.close
      end
    end
    
    def kill!
      @socket.close
      @worker.kill!
    end
  end  
end

