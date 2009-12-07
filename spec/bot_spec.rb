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

  it "parses a YAML config file from $HOME/.numbr6rc on startup" do
    YAML.should_receive(:load_file).with("#{ENV['HOME']}/.numbr6rc")
    Numbr6::Bot.new
  end

  it "tweets beer owings to an account specified in the config file" do
    @bot.instance_variable_get(:@twitter).should_receive :status
    @server.broadcast ":julio!n=julio@ppp245-110.static.internode.on.net PRIVMSG #nomodicum :ACTION thanks foo for bar"
    sleep 0.1
  end
  
  it "figures how many beers a user is owed off of a Twitter search" do
    twitter = @bot.instance_variable_get(:@twitter)
    twitter.stub(:search).and_return([])
    @bot.instance_variable_get(:@twitter).should_receive :search
    @server.broadcast ":julio!n=julio@67-207-128-123.slicehost.net PRIVMSG #nomodicum :#{@bot.config[:nick]}: stat"
    sleep 0.1
  end
  
  it "writes a log file to $HOME/.numbr6/numbr6.log if no log location is specified"
  it "writes a log file to a location specified in the config file if there's such a thing"

  it "responds with how many beers a user is owed on STAT"
end