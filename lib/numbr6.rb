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
    attr_accessor :logger, :config
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
      log :debug, message.strip!
      case message
      when /no ident/i
        identify_and_join!
      when /^PING /
        pong
      when /:([^!]+).+ PRIVMSG ##{@config[:channel]} :.* thanks (\w+) (.+)/
        user, who, reason = $1, $2, $3
        thank user, who, reason
        say "#{user} owes #{who} a beer #{reason}"
      when /:([^!]+).+ PRIVMSG ##{@config[:channel]} :#{@config[:nick]}[:\s]*stat/
        count = total_beers_for $1
        say "#{$1}: You're owed #{count} beers."
      end
    end
    
    def thank(user, who, reason)
      return false if user == who
      if @twitter
        log :info, "#{user} thanks #{who} #{reason}"
        @twitter.status :post, "#{user} owes #{who} a beer #{reason}"
      else
        log :warn, "This humble bot cannot tweet without a Twitter account"
      end
    end
    
    def say(message)
      message "PRIVMSG ##{@config[:channel]} :#{message}"
    end
    
    def total_beers_for(user)
      @twitter.search(:q => "#{user} thanks", :from => @config[:nick]).length
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