#!/usr/bin/env ruby
require 'socket'
require 'logger'

CONFIG = { :server => 'irc.freenode.net', :port   => 6667, :channel => 'nomodicum', :nick => "numbr6_#{rand(9999)}" }

TCPSocket.do_not_reverse_lookup = true

module Numbr6
  module Messages
    NO_IDENT  = /no ident/i
    PING      = /^PING /
    PRIVATE   = / PRIVMSG #{CONFIG[:nick]} /
    PUBLIC    = / PRIVMSG ##{CONFIG[:channel]}/
  end  
  
  class Bot
    include Messages
    def initialize(config = {})
      @config = CONFIG.merge config
      @logger = Logger.new(STDOUT)
      @socket = TCPSocket.new @config[:server], @config[:port]
      @reader = Thread.start do
        loop do
          if io = select([@socket], nil, nil) then process io[0][0].readline end
        end
      end
    end

    def run
      @logger.info "Numbr6::Bot running..."
      sleep
    end

    private

    def process(message)
      @logger.debug message.sub(/\n$/, '')
      case message
      when NO_IDENT
        identify_and_join!
      when PING
        pong
      end
    end

    def identify_and_join!
      message "NICK #{@config[:nick]}"
      message "USER #{@config[:nick]} 0 * :Number 5"
      message "JOIN ##{@config[:channel]}"    
    end
    
    def pong
      @logger.debug "PONGing"
      message 'PONG irc'
    end
    
    def message(data)
      @socket.puts data
    end
  end
end

if $0 =~ /spec$/
  require 'spec'
  require File.join(File.dirname(__FILE__), '..', 'spec', 'spec_helper')

  describe Numbr6 do
    before :all do
      @server = Numbr6::FauxIRCServer.new 9999
    end

    it "identifies itself and joins the channel in CONFIG after connecting" do
      @server.emulate :no_ident
      @bot = Numbr6::Bot.new :server => '0.0.0.0', :port => 9999
      # @bot.should_receive(:identify_and_join!)
      @bot.run
    end  
  end
end