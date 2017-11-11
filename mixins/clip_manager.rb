require 'sequel'

CLIPS = Sequel.sqlite('db/reports.db') # memory database, requires sqlite3

CLIPS.create_table? :clips do
  primary_key :id
  String :parsed_message
  String :url
  String :author
  DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
end

class Clip < Sequel::Model

  def self.add_report(klass)
    self.new do |report|
      report.parsed_message = klass.parsed_message.join(",")
      report.author =         klass.author.join(",")
      report.url =            klass.url.join(",")
      report.save
    end
  end

end