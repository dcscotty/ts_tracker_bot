require_relative 'message_processor'
require_relative 'report_manager'
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
    report_messenger(event: event, report_type: type, days: days)
  when '#followtwo'
    report_messenger(event: event, report_type: type, days: days)
  else
    event.respond "I'm sorry Dave, I can't do that."
  end
end

def report_messenger(event:, report_type:, days:)
  event.respond "Querying for #{report_type} over the last #{days} days!"
  reports = Report.where{(created_at >= Date.today - days.to_i) & (channels.like("%#{report_type}%"))}.all
  event.respond "#{reports.length} reports found. Report starting:"
  reports.each do |report|
    event.respond "================================================"
    event.respond "**Member**: `#{report.author}`\n**Message:** `#{report.parsed_message}`\n**Channel:** `#{report.channel_origin}`"
  end
  event.respond "================================================"
  event.respond "End of report."  
end

bot.run
