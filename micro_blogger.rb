require 'jumpstart_auth'
require 'pry'
require 'bitly'
require 'klout'

class MicroBlogger
  attr_reader :client
  attr_reader :bitly


  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
    Bitly.use_api_version_3
    @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def tweet(message)
      send_tweet(message)
      puts "Posted tweet #{message}"
  end

  def send_tweet(message)
    if message.length <= 140
      client.update(message)
    else
      puts "Sorry, your message is too long :("
    end
  end

  def direct_message(username, message)
    if my_followers.include?(username)
      send_tweet "dm #{username} #{message}"
      puts "Sent a DM to #{username} with content"
    else
      puts "Sorry #{username} does not follow you."
    end
  end

  def my_followers
    client.followers.collect { |f| f.screen_name}
  end

  def spam_my_followers(message)
    my_followers.each do |follower|
      direct_message(follower, message)
    end
  end

def everyones_last_tweet
  friends = client.friends.sort_by do |friend|
    friend.screen_name.downcase
  end

  friends.each do |user|
    print "#{user.name} (#{user.screen_name}) said: "
    print user.status.text
    timestamp = user.status.created_at
    formatted_time = timestamp.strftime("%A, %b %d")
    puts " on #{formatted_time}"
    puts ""
  end
end

  def run
    puts "Welcome to MicroBlogger!"
    command = ""

    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split
      command = parts[0]
      username = parts[1]
      puts "Got command: #{command.inspect}"

      case command
        when 'q' then puts "Goodbye!"
        when 't' then
          message = parts[1..-1].join(" ")
          tweet(message)
        when 'dm' then
          message = parts[2..-1].join(" ")
          direct_message(username, message)
        when "followers" then
          puts my_followers
        when "spam" then 
          message = parts[1..-1].join(" ")
          spam_my_followers(message)
        when "elt" then 
          everyones_last_tweet
        when "turl" then
          message = parts[1..-1].join(" ")
          tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1])) 
        when "klout" then klout_score
        else puts "Sorry I don't know how to '#{command}'"
      end
    end
  end

  def shorten(original_url)
    puts "Shortening this URL: #{original_url}"
    url = bitly.shorten(original_url).short_url
    return url
  end

  def klout_score
    friends = client.friends.collect{|f| f.screen_name}
    friends.each do |friend|
      identity = Klout::Identity.find_by_screen_name(friend)
      user = Klout::User.new(identity.id)
      klout_score = user.score.score
      print "#{friend} has a klout of: "
      print klout_score
      puts ""
    end
  end
end

mb = MicroBlogger.new
mb.run
mb.klout_score


