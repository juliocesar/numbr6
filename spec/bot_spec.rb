require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Numbr6::Bot do
  before :all do
    @server = Fauxy.new.run
    @bot = Numbr6::Bot.new :server => '0.0.0.0', :port => 9999
    @bot.run
  end
  
  it "identifies itself and joins the channel in CONFIG after connecting" do
    @bot.should_receive :identify_and_join!
    @server.broadcast "NOTICE AUTH :*** No identd (auth) response"
    sleep 0.1
  end

  it "responds to PING requests from the server" do
    @bot.should_receive :pong
    @server.broadcast "PING :card.freenode.net"
    sleep 0.1
  end
  
  it "writes a YAML config file to $HOME/.numbr6rc on start if one doesn't exist" do
    FileUtils.rm "#{ENV['HOME']}/.numbr6rc"
    @bot = Numbr6::Bot.new :server => '0.0.0.0', :port => 9999
    @bot.stop
    YAML.load_file("#{ENV['HOME']}/.numbr6rc").should be_an_instance_of Hash
  end
  
  it "parses a YAML config file from $HOME/.numbr6rc on startup" do
    File.open("#{ENV['HOME']}/.numbr6rc", 'w') { |f| f << DEFAULTS.to_yaml }
    @bot = Numbr6::Bot.new :server => '0.0.0.0', :port => 9999
    @bot.should_receive :read_config
  end
  
  it "writes a log file to $HOME/.numbr6/numbr6.log if no log location is specified"
  it "writes a log file to a location specified in the config file if there's such a thing"

  it "tweets beer owings to an account specified in the config file"
  it "figures how many beers a user is owed off of a Twitter search"

  it "responds with how many beers a user is owed on STAT"
end