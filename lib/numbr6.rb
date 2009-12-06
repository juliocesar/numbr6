#!/usr/bin/env ruby
require 'socket'
require 'logger'
require 'fileutils'
require 'yaml'

DEFAULTS = { :server => 'irc.freenode.net', :port   => 6667, :channel => 'nomodicum', :nick => "numbr6_#{rand(9999)}" }

TCPSocket.do_not_reverse_lookup = true
Thread.abort_on_exception = true

module Numbr6
  module Messages
    NO_IDENT  = /no ident/i
    PING      = /^PING /
    PRIVATE   = /PRIVMSG #{DEFAULTS[:nick]} /
    THANK     = /:([^!]+).+ PRIVMSG ##{DEFAULTS[:channel]} :ACTION thanks (\w+) (.+)/
  end

  class Bot
    attr_accessor :logger
    include Messages
    def initialize(config = {})
      @config = DEFAULTS.merge(config)
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
      self
    end

    def stop
      begin
        @reader.kill!
        @socket.close
      rescue Exception
      end
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
      when THANK
        all, user, who, reason = *THANK.match(message)
        thank user, who, reason
      end
    end
    
    def thank(user, who, reason)
      
    end

    def identify_and_join!
      message "NICK #{@config[:nick]}"
      message "USER #{@config[:nick]} 0 * :Number 5"
      message "JOIN ##{@config[:channel]}"
    end

    def pong
      log :debug, 'pong!'
      message 'PONG irc'
    end

    def message(data)
      @socket.puts data
    end
    
    def log(level, message)
      @logger.send(level || :info, message) if @logger
    end
    
    def write_config
      File.open("#{ENV['HOME']}/.numbr6rc", 'w') { |f| f << @config.to_yaml }
    end
    
    def read_config
      YAML.load_file("#{ENV['HOME']}/.numbr6rc") rescue nil
    end
  end
end