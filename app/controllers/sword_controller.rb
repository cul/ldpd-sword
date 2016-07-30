require "sword/deposit_request"

class SwordController < ApplicationController
  before_action :check_for_valid_collection_slug, only: [:deposit]

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

  private
    def check_for_valid_collection_slug
      @collection = Collection.find_by slug: params[:collection_slug]
      # may want to do redirect_to or render something instead. For now, do this
      head :bad_request if (@collection.nil?)
    end

    def check_basic_http_authentication

    end
end

