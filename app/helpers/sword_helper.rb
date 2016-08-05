require 'builder'
module SwordHelper
  def servicedocument_xml(user_conf, http_host)

    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct! :xml, :encoding => "utf-8"
    xml.tag!("service", 
              {"xmlns"=>"http://www.w3.org/2007/app", 
               "xmlns:atom" => "http://www.w3.org/2005/Atom",
               "xmlns:sword" => "http://purl.org/net/sword/",
               "xmlns:dcterms" => "http://purl.org/dc/terms/"}) do |service|
  
      service.tag!("sword:version", "1.3") 
      service.tag!("sword:verbose", user_conf["sword_verbose"])
      service.tag!("sword:noOp", user_conf["sword_noOp"])
  
      service.workspace do |workspace|
        workspace.tag!("atom:title", "Academic Commons - SWORD Service")
        workspace.tag!("collection", {"href"=> "http://" + http_host + "/sword/deposit/" + user_conf["collection"]}) do |collection|
          collection.tag!("atom:title", user_conf["atom_title"])
          collection.tag!("dcterms:abstract", user_conf["dcterms_abstract"])
          
          user_conf["sword_content_types_supported"].each do |content_type|
            collection.accept content_type 
          end 
          
          user_conf["sword_packaging_accepted"].each do |packaging_accepted|
            collection.tag!("sword:acceptPackaging", {"q"=>"1.0"}, packaging_accepted)
          end 
          
          collection.tag!("sword:mediation", user_conf["sword_mediation"])
        end 
   
      end
    end
  end
end
