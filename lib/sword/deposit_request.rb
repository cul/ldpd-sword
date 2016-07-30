# fcd1, 07/30/16: Original code copied from hypatia-new from lib/deposits/sword/desposit.rb
module Sword
class DepositRequest

  attr_accessor :request,
                :user_name,
                :password,
                :on_behalf_of,
                :content_type,
                :file_name,
                :packaging,
                :collection,
                :user_agent,
                :request_url,
                :content,                
                :header_md5_digest,
                :content_md5_digest
                
# fcd1, 07/30/16: Do I really need the collection, it is not part of the request
  def initialize(request, collection)
    @request = request
    pullCredentials(request)
    @on_behalf_of = request.headers["X-On-Behalf-Of"]
    @content_type = request.headers["CONTENT_TYPE"]
    @packaging = request.headers["X-Packaging"]
    @collection = collection
    @user_agent = request.headers["USER_AGENT"]
    @request_url = request.url
    @header_md5_digest = request.headers["CONTENT_MD5"]
    pullContent(request)
    
    Rails.logger.info "request_url =        '" + request_url + "'"
    Rails.logger.info "user_name =          '" + (@user_name.nil? ? '' : @user_name) + "'"
    Rails.logger.info "on_behalf_of =       '" + (@on_behalf_of.nil? ? '' : @on_behalf_of) + "'"
    Rails.logger.info "packaging =          '" + (@packaging.nil? ? '' : @packaging) + "'"
    Rails.logger.info "content_type =       '" + (@content_type.nil? ? '' : @content_type) + "'"
    Rails.logger.info "file_name =          '" + (@file_name.nil? ? '' : @file_name) + "'"
    Rails.logger.info "packaging =          '" + (@packaging.nil? ? '' : @packaging) + "'"
    Rails.logger.info "collection =         '" + (@collection.nil? ? '' : @collection) + "'"
    Rails.logger.info "user_agent =         '" + (@user_agent.nil? ? '' : @user_agent) + "'"
    Rails.logger.info "header_md5_digest =  '" + (@header_md5_digest.nil? ? '' : @header_md5_digest) + "'"
    Rails.logger.info "content_md5_digest = '" + (@content_md5_digest.nil? ? '' : @content_md5_digest) + "'"
    
  end   
  
  def pullContent(request)
    @content = request.body.read
    @content_md5_digest = Digest::MD5.hexdigest(@content)
    @file_name = pullContentFileName(request)
    
    if(@file_name.nil? || @file_name.empty?)
      @file_name = @content_md5_digest + '.zip'
    end
  end

  def pullContentFileName(request)
      content_disposition = String.new(request.headers["CONTENT_DISPOSITION"].to_s)
      Rails.logger.info "====== origin content_disposition: " + content_disposition
      if(content_disposition.include? 'filename=')
        content_disposition['filename='] = ''
      end  
      Rails.logger.info "====== clean content_disposition: " + content_disposition
      return content_disposition
  end   
  
  def pullCredentials(request)
     authorization = String.new(request.headers["Authorization"].to_s)
     
     if(authorization.include? 'Basic ')
       authorization['Basic '] = ''
       authorization = Base64.decode64(authorization)
       credentials = authorization.split(":")
       @user_name = credentials[0] 
       @password = credentials[1]
     end
  end  

end

end
