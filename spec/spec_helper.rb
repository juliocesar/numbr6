require 'spec'
require 'timeout'
require File.join(File.dirname(__FILE__), '..', 'lib', 'numbr6')

class Fauxy
  def initialize(port = 9999)
    @messages = {}
    @socket = TCPServer.new '0.0.0.0', port
    @clients = []
  end
  
  def run  
    @responder = Thread.new do
      loop do
        Thread.start(@socket.accept) do |client|
          @clients << client
        end
      end
    end
    self
  end
  
  def broadcast(message)
    @clients.each do |client|
      client.puts message
    end
  end
    
  def stop
    @socket.close
    @responder.kill
  end
end