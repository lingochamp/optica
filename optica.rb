require 'sinatra/base'
require 'json'
require 'cgi'

class Optica < Sinatra::Base
  get '/' do
    params = CGI::parse(request.query_string)

    # include only those nodes that match passed-in parameters
    to_return = {}
    settings.store.nodes.each do |node, properties|
      included = true

      params.each do |param, values|
        values.each do |value|
          if not properties.include? param
            included = false
          elsif properties[param].is_a? String
            included = false unless properties[param] == value
          elsif properties[param].is_a? Array
            included = false unless properties[param].include? value
          end
        end
      end

      to_return[node] = properties if included
    end

    return to_return.to_json
  end

  post '/' do
    begin
      data = JSON.parse request.body.read
    rescue JSON::ParserError
      data = {}
    end

    settings.store.add(request.ip, data)
    return 'stored'
  end

  get '/health' do
    return "OK"
  end
end