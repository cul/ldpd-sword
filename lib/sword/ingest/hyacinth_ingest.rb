module Sword
module Ingest
class HyacinthIngest

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

    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(post_req) }
  end
end
end
end
