class CollectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_to_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_collection, only: [:show, :edit, :update, :destroy]

  # GET /collections
  # GET /collections.json
  def index
    @collections = Collection.all
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
  end

  # GET /collections/new
  def new
    @collection = Collection.new
    @parsers = SWORD_CONFIG[:parsers]
    @list_of_parsers
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections
  # POST /collections.json
  def create
    @collection = Collection.new(collection_params)

    respond_to do |format|
      if @collection.save
        format.html { redirect_to @collection, notice: 'Collection was successfully created.' }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: 'Collection was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end

    def restrict_to_admin
      redirect_to(collections_path, notice: "Only admin can perform this action") unless current_user.admin?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      # params.fetch(:collection, {})
      params.require(:collection).permit(:name,
                                         :atom_title,
                                         :slug,
                                         :abstract,
                                         :hyacinth_project_string_key,
                                         :parser,
                                         :mime_types,
                                         :sword_package_types,
                                         :mediation_enabled )
    end
end
