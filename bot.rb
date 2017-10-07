require_relative 'mixins/message_processor'
require_relative 'mixins/report_manager'
require_relative 'mixins/messenger'
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

bot.run
