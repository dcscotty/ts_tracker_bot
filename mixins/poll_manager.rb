require 'rest-client'

class PollManager
  REQUEST_URL = 'https://strawpoll.me/api/v2/polls'
  attr_reader :title, :options, :poll_link

  def initialize(poll_args:)
    @title = poll_args.first
    @options = poll_args.drop(1)
  end

  def create
    poll = create_poll
    @poll_link = poll_url(id: JSON.parse(poll.body)["id"])
  end

  private

  def create_poll
    begin
      RestClient.post(REQUEST_URL, request_body.to_json, headers = {content_type: :json})
    rescue RestClient::ExceptionWithResponse => error
      case error.http_code
      when 301, 302, 307
        error.response.follow_redirection
      else
        raise
      end 
    end
  end

  def poll_url(id:)
    "http://www.strawpoll.me/#{id}"
  end

  def request_body
    {
      "title": title,
      "options": options,
      "multi": false
    }
  end

end
