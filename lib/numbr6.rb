#!/usr/bin/env ruby
require 'socket'
require 'logger'
require 'fileutils'
require 'yaml'
gem 'twitter4r', '0.3.2'
require 'twitter'

DEFAULTS = { :server => 'irc.freenode.net', :port   => 6667, :channel => 'nomodicum', :nick => "numbr6_#{rand(9999)}" }

TCPSocket.do_not_reverse_lookup = true
Thread.abort_on_exception = true

module Numbr6
  class Bot
    attr_accessor :logger
    def initialize(config = {})
      @config = DEFAULTS.merge(read_config || {}).merge(config)
      if @config[:twitter]
        @twitter = Twitter::Client.new :login => @config[:twitter][:login], :password => @config[:twitter][:password]
      else
        log :warn, "No Twitter account info found. Owings won't be saved"
      end
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
      puts "GOT: #{message}"
      log :debug, message.strip!
      case message
      when /no ident/i
        identify_and_join!
      when /^PING /
        pong
      when /:([^!]+).+ PRIVMSG ##{@config[:channel]} :ACTION thanks (\w+) (.+)/
        # puts 'got THANK'
        # all, user, who, reason = *THANK.match(message)
        # thank user, who, reason
        # say "#{user} owes #{who} a beer #{reason}"
      when /PRIVMSG #{@config[:nick]} /
        
      end
    end
    
    def thank(user, who, reason)
      return false if user == who
      log :info, "#{user} thanks #{who} #{reason}"
      @twitter.status :post, "#{user} thanks #{who} #{reason}"
    end
    
    def say(message)
      message "PRIVMSG ##{@config[:channel]} :#{message}"
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
    
    def read_config
      YAML.load_file("#{ENV['HOME']}/.numbr6rc") rescue nil
    end
  end
end