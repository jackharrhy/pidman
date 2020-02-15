require "discordcr"
require "dotenv"

begin
  Dotenv.load
end

prefix = ENV["PIDMAN_PREFIX"]

discord_token = ENV["PIDMAN_DISCORD_TOKEN"]
discord_client_id = ENV["PIDMAN_DISCORD_CLIENT_ID"].to_u64

client = Discord::Client.new(token: "Bot #{discord_token}", client_id: discord_client_id)
cache = Discord::Cache.new(client)
client.cache = cache

@[Link(ldflags: "#{__DIR__}/pidman.o")]

lib Pidman
  fun allocate_pid : Int32
  fun release_pid(pid : Int32)
end

ownership = Hash(Discord::Snowflake, Int32).new

client.on_message_create do |message|
  next if message.author.bot
  msg = message.content

  begin
    next if !msg.starts_with? prefix

    if msg.starts_with? "#{prefix}allocate"
      if ownership.has_key? message.author.id
        client.create_message message.channel_id, "you already have a PID!: #{ownership[message.author.id]}"
      else
        new_pid = Pidman.allocate_pid()
        ownership[message.author.id] = new_pid
        client.create_message message.channel_id, "here, have a PID: #{new_pid}"
      end
    end

    if msg.starts_with? "#{prefix}release"
      if ownership.has_key? message.author.id
        pid = ownership[message.author.id]
        client.create_message message.channel_id, "you have lost your PID!: #{pid}"
        Pidman.release_pid(pid)
        ownership.delete(message.author.id)
      else
        client.create_message message.channel_id, "you don't have a PID!"
      end
    end
  rescue ex
    puts ex.inspect_with_backtrace
    client.create_message message.channel_id, "```#{ex.inspect_with_backtrace}```"
  end
end

Signal::INT.trap do
  puts "pidman killed .-."
  exit
end

puts "pidman ready!"
client.run