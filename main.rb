# Manual: 
# curl localhost:4567/account -d "name=obskein"
# curl localhost:4567/account/obskein 
# curl localhost:4567/account/obskein/exist



require 'bundler/setup'

require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'yaml'
require 'securerandom'
require 'pp'
require_relative 'firestarter'

set :bind, '0.0.0.0'

configure { set :server, :puma }

=begin
set :environment, :production

error do
  status 500
  JSON.dump({:result => '500', :message => "server error"})
end

not_found do
  status 404
  JSON.dump({:result => '404', :message => "does not exist"})
end
=end

require 'logger'

configure :development do
  set :logging, Logger::DEBUG
end


post '/wallet' do
  json_body = JSON.load(request.body.read)
  keys = json_body["keys"]
  @firestarter = Firestarter.new()
  res = @firestarter.create_wallet(keys)
  if res["error"]
    status 500
    message = res["error"]["message"]
    JSON.dump({:result => '500', :message => message, :full => res})
  else
    JSON.dump(res)
  end
end
