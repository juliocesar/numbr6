require 'rubygems'
require 'socket'
require 'ruby-debug'

CONFIG = { :server => 'irc.freenode.net', :port   => 6667, :channel => 'nomodicum', :nick => "numbr6_#{rand(9999)}" }

TCPSocket.do_not_reverse_lookup = true

class Numbr6
  def initialize
    @socket = TCPSocket.new CONFIG[:server], CONFIG[:port]
    @reader = Thread.start do
      loop do
        if io = select([@socket], nil, nil) then process io[0][0].readline end
      end
    end
  end
  
  def run
    puts "running..."
    sleep
  end
  
  private
  
  def process(message)
    puts "LOG: " + message
    case message
    when /no ident/i
      identify_and_join!
    end
  end
  
  def identity_and_join!
    @socket.puts "NICK #{CONFIG[:nick]}"
    @socket.puts "USER #{CONFIG[:nick]} 0 * :Number 5"
    @socket.puts "JOIN ##{CONFIG[:channel]}"    
  end
end

Numbr6.new.run