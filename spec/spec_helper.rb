module Numbr6
  class FauxIRCServer
    def initialize
      @socket = TCPServer.new '0.0.0.0', 99999
      @worker = Thread.start(@socket.accept) do |client|
        while line = client.readline do
        end
      end
    end
    
    def kill!
      @socket.close
      @worker.kill!
    end
  end  
end

