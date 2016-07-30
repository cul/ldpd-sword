class SwordController < ApplicationController
  def deposit
    @collection = Collection.find_by slug: params[:collection_slug]
  end
end
