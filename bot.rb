Dir['./mixins/*'].each {|file| require file }
require 'dotenv/load'
require 'discordrb'

bot = Discordrb::Commands::CommandBot.new token: ENV['BOT_TOKEN'], client_id: ENV['CLIENT_ID'], prefix: '!'

puts "#{bot.invite_url}"

bot.message(contains: ENV['CHANNEL_MENTIONS'].split(','), in: ENV['TARGET_CHANNEL'].to_i) do |event|
  message = MessageProcessor.new(event: event, bot: bot)
  Report.add_report(message)
end

bot.command(:report, min_args: 2, max_args: 2, channels: [ENV['REPORT_CHANNEL'].to_i], description: 'Returns a report for #spent10 or #followtwo and the number of days in the past specified. Usage: !report #spent10 21') do |event, type, days|
  case type
  when '#spent10'
    Messenger.report(event: event, report_type: type, days: days)
  when '#followtwo'
    Messenger.report(event: event, report_type: type, days: days)
  else
    event.respond "I'm sorry Dave, I can't do that."
  end
end

bot.command(:createpoll, description: 'Creates a poll on strawpoll.me. Usage: !createpoll Title, Option A, Option B, Option C') do |event, *args|
  poll_arguments = args.join(' ').split(', ')
  @pm = PollManager.new(poll_args: poll_arguments)
  @pm.create # Creates the poll and sets the attribute poll_link/poll_results on @pm
  event.respond "Vote here: #{@pm.poll_link}"
end

bot.command(:poll, description: 'Returns the link to the last created poll') do |event|
  if @pm
    event.respond "The last created poll can be found here: #{@pm.poll_link}"
  else
    event.respond "A poll must be previously created (or I have gone offline since the last poll was made)."
  end
end

bot.run
