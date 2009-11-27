#!/usr/bin/env ruby
require 'socket'
require 'logger'

CONFIG = { :server => 'irc.freenode.net', :port   => 6667, :channel => 'nomodicum', :nick => "numbr6_#{rand(9999)}" }

TCPSocket.do_not_reverse_lookup = true
Thread.abort_on_exception = true

module Numbr6
  module Messages
    NO_IDENT  = /no ident/i
    PING      = /^PING /
    PRIVATE   = / PRIVMSG #{CONFIG[:nick]} /
    PUBLIC    = / PRIVMSG ##{CONFIG[:channel]}/
  end

  class Bot
    attr_accessor :logger
    include Messages
    def initialize(config = {})
      @config = CONFIG.merge config
      @logger = @config[:logger]
    end

    def run
      log :info, "Numbr6::Bot running..."
      @socket = TCPSocket.new @config[:server], @config[:port]
      @reader = Thread.start do
        loop do
          if io = select([@socket], nil, nil) then process io[0][0].readline end
        end
      end
      sleep
    end

    def stop
      @reader.kill!
      @socket.close
      log :info, "Numbr6::Bot stopped!"
    end

    private

    def process(message)
      log :debug, message.sub(/\n$/, '')
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
      message 'PONG irc'
    end

    def message(data)
      @socket.puts data
    end
    
    def log(level, message)
      @logger.send(level || :info, message) if @logger
    end
  end
end

if $0 =~ /spec$/
  require File.join(File.dirname(__FILE__), '..', 'spec', 'spec_helper')

  describe Numbr6 do
    before :all do
      @server = Numbr6::FauxIRCServer.new 9999
    end
    
    after :each do
      @bot.stop
    end

    it "identifies itself and joins the channel in CONFIG after connecting" do
      @server.emulate :no_ident
      @bot = Numbr6::Bot.new :server => '0.0.0.0', :port => 9999
      @bot.should_receive :identify_and_join!
      timesout_shortly do @bot.run end
    end
    
    it "responds to PING requests from the server" do
      @server.emulate :ping
      @bot = Numbr6::Bot.new :server => '0.0.0.0', :port => 9999
      @bot.should_receive :pong
      timesout_shortly do @bot.run end
    end
  end
end