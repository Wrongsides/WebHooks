require 'sinatra'
require 'json'
require 'octokit'

# Set port for compatability with Nitrous.IO 
configure :development do   
  set :bind, '0.0.0.0'
  set :port, 3000 # Not really needed, but works well with the "Preview" menu option
end

ACCESS_TOKEN = ENV['MY_KEY']

before do
  @client ||= Octokit::Client.new(:access_token => ACCESS_TOKEN)
end

post '/event_handler' do
  @payload = JSON.parse(request.body.read)

  case request.env['HTTP_X_GITHUB_EVENT']
  when "pull_request"
    if @payload["action"] == "opened"
      process_pull_request(@payload["pull_request"])
    end
  end
end

helpers do
  def process_pull_request(pull_request)
    @client.create_status(pull_request['base']['repo']['full_name'], pull_request['head']['sha'], 'pending')
    sleep 2 # do busy work...
    @client.create_status(pull_request['base']['repo']['full_name'], pull_request['head']['sha'], 'success')
    puts "Pull request processed!"
  end
end
