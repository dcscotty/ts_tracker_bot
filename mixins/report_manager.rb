require 'sequel'

REPORTS = Sequel.sqlite('db/reports.db') # memory database, requires sqlite3

REPORTS.create_table? :reports do
  primary_key :id
  String :parsed_message
  String :author
  String :mentions
  String :channels
  String :channel_origin
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end

class Report < Sequel::Model

  def self.add_report(klass)
    # Expects the MessageProcessor class
    self.new do |report|
      report.parsed_message = klass.parsed_message.join(",")
      report.author =         klass.author.join(",")
      report.mentions =       klass.mentions.join(",")
      report.channels =       klass.channels.join(",")
      report.channel_origin = klass.channel_origin.join(",")
      report.save
    end
  end

end
