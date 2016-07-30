require "sword/deposit_request"
class SwordController < ApplicationController
  def deposit
    # puts request.inspect if Rails.env.development? or Rails.env.test?
    @collection = Collection.find_by slug: params[:collection_slug]
    if @collection.nil? 
      # change this logic. Can't remember if rubocop likes return mid-method
      head :bad_request and return
    end
    # get authorization info
    puts Sword::DepositRequest.new(request, @collection.slug).inspect
  end
end

