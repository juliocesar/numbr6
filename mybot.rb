#!/usr/bin/env ruby
require 'socket'

CONFIG = { :server => 'irc.freenode.net', :port   => 6667, :channel => 'nomodicum', :nick => "numbr6_#{rand(9999)}" }

TCPSocket.do_not_reverse_lookup = true

module Numbr6
  class Bot
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

    def identify_and_join!
      @socket.puts "NICK #{CONFIG[:nick]}"
      @socket.puts "USER #{CONFIG[:nick]} 0 * :Number 5"
      @socket.puts "JOIN ##{CONFIG[:channel]}"    
    end
  end
end


Numbr6::Bot.new.run unless $0 =~ /spec$/

require 'spec'
require File.join(File.dirname(__FILE__), 'spec', 'spec_helper')

describe Numbr6 do
  before do
    @server = Numbr6::FauxIRCServer.new
  end
  
  it "identifies itself and joins the channel in CONFIG after connecting" do
  end  
end