require 'net/http'
module Sword
module Ingest
class HyacinthIngest

  class Response
    def initialize(response)
      @response = response
    end

    def http_code_success_2xx?
      return (Integer(@response.code)/100) == 2
    end

    def success?
      return @response.body['success']
    end

    def pid
      JSON.parse(@response.body)['pid']
    end

    def body
      @response.body
    end

    def code
      @response.code
    end

    def message
      @response.message
    end

    def hint
      case code
      when '401'
        "HINT: Check hyacinth credentials (hyacinth.yml)-- credentials correct and user exists in hyacinth"
      when '403'
        "HINT: Check hyacinth user has create privs in the hyacinth project"
      else
        "HINT: Sorry, no hint available"
      end
    end
  end

  # takes a  HyacinthCompose object and the project in hyacinth
  def ingest_json(data_json)
    payload = {}
    payload[:digital_object_data_json] = data_json
    payload_json = JSON.generate payload
    # puts payload_json
    uri = URI(HYACINTH_CONFIG[:url])
    # res = Net::HTTP.get(uri)
    # puts res
    post_req = Net::HTTP::Post.new(uri)
    post_req.set_form_data("digital_object_data_json" => data_json)
    post_req.basic_auth(HYACINTH_CONFIG[:username],
                        HYACINTH_CONFIG[:password])
    res = Response.new(Net::HTTP.start(uri.hostname,
                                       uri.port,
                                       use_ssl: HYACINTH_CONFIG[:use_ssl]) { |http| http.request(post_req) } )
  end
end
end
end
