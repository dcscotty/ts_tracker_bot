require_relative 'report_manager'

class Messenger

  def self.report(event:, report_type:, days:)
    event.respond "Querying for #{report_type} over the last #{days} days!"
    reports = Report.where{(created_at >= Date.today - days.to_i) & (channels.like("%#{report_type}%"))}.all
    if reports.length == 0
      event.respond "No reports found."
    else
      event.respond "#{reports.length} reports found. Report starting:"
      reports.each do |report|
        event.respond "================================================"
        event.respond "**Member**: `#{report.author}`\n**Message:** `#{report.parsed_message}`\n**Channel:** `#{report.channel_origin}`"
      end
      event.respond "================================================"
      event.respond "End of report."  
    end
  end

end
