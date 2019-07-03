# Manual: 
# curl localhost:4567/account -d "name=obskein"
# curl localhost:4567/account/obskein 
# curl localhost:4567/account/obskein/exist



require 'bundler/setup'

require 'sinatra'
require 'json'
require 'yaml'
require 'securerandom'
require 'pp'
require_relative 'firestarter'

$config = YAML.load_file('config.yml')["development"]["xgt"]

set :bind, '0.0.0.0'



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


get '/account/:name' do
  @firestarter = Firestarter.new($config)
  JSON.dump({ accounts: @firestarter.account(params[:name]) })
end

get '/account/:name/exist' do
  @firestarter = Firestarter.new($config)
  JSON.dump({ account_exist?: @firestarter.account_exist?(params[:name]) })
end
 
post '/account' do
  # name = params[:name]
  json_body = JSON.load(request.body.read)
  keys = json_body["keys"]
  name = "xgt" + SecureRandom.uuid
  @firestarter = Firestarter.new($config)
  res = @firestarter.create_account(name, keys)
  if res["error"]
    status 500
    message = res["error"]["message"]
    JSON.dump({:result => '500', :message => message, :full => res})
  else
    JSON.dump(res)
  end
end
