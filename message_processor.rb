class MessageProcessor
  CHANNEL_PATTERN =   /<#([0-9]+)>/
  USER_PATTERN =      /<@!?([0-9]+)>/

  attr_reader :bot, :parsed_message, :author, :mentions, :channels, :channel_origin

  def initialize(event:, bot:)
    @bot = bot
    copied_message = copy_message(message: event.content)
    @mentions = resolve_users(uids: parse_object(message: copied_message, pattern: USER_PATTERN))
    @channels = resolve_channels(cids: parse_object(message: copied_message, pattern: CHANNEL_PATTERN))
    @parsed_message = rebuild_message(message: copied_message, users: @mentions, channels: @channels)
    @author = resolve_users(uids: [event.message.author.id])
    @channel_origin = resolve_channels(cids: [event.message.channel.id])
  end

  def rebuild_message(message:, users:, channels:)
    resolved_message = sub_message_content(message: message, items: users, pattern: USER_PATTERN)
    resolved_message = sub_message_content(message: message, items: channels, pattern: CHANNEL_PATTERN)
    [resolved_message] # Caveat to making sure data types are consistent across attributes in MessageProcessor
  end

  def parse_object(message:, pattern:)
    items = message.scan(pattern).flatten
    item_ids = items.map(&:to_i)
  end

  def copy_message(message:)
    message.dup
  end

  def sub_message_content(message:, items:, pattern:)
    items.each do |item|
      message.sub!(pattern, item)
    end
    message
  end

  def resolve_channels(cids:)
    channels = Array.new
    cids.each do |channel_id|
      channels << "##{@bot.channel(channel_id).name}"
    end
    channels
  end

  def resolve_users(uids:)
    mentions = Array.new
    uids.each do |user_id|
      user = @bot.users[user_id]
      mentions << "@#{user.username}##{user.discriminator}"
    end
    mentions
  end

end
