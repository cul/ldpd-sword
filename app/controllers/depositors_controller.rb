class DepositorsController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_to_admin, only: [:new, :create, :edit, :update, :destroy,
                                           :edit_permissions, :remove_permission, :add_permission]
  before_action :set_depositor, only: [:show, :edit, :update, :destroy,
                                       :edit_permissions, :remove_permission, :add_permission]

  # GET /depositors
  # GET /depositors.json
  def index
    @depositors = Depositor.all
  end

  # GET /depositors/1
  # GET /depositors/1.json
  def show
  end

  # GET /depositors/new
  def new
    @depositor = Depositor.new
  end

  # GET /depositors/1/edit
  def edit
  end

  # POST /depositors
  # POST /depositors.json
  def create
    @depositor = Depositor.new(depositor_params)

    respond_to do |format|
      if @depositor.save
        format.html { redirect_to @depositor, notice: 'Depositor was successfully created.' }
        format.json { render :show, status: :created, location: @depositor }
      else
        format.html { render :new }
        format.json { render json: @depositor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /depositors/1
  # PATCH/PUT /depositors/1.json
  def update
    respond_to do |format|
      if @depositor.update(depositor_params)
        format.html { redirect_to @depositor, notice: 'Depositor was successfully updated.' }
        format.json { render :show, status: :ok, location: @depositor }
      else
        format.html { render :edit }
        format.json { render json: @depositor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /depositors/1
  # DELETE /depositors/1.json
  def destroy
    @depositor.destroy
    respond_to do |format|
      format.html { redirect_to depositors_url, notice: 'Depositor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def edit_permissions
    @has_access_to_collection = {}
    Collection.all.each do |collection|
      if @depositor.collections.include? collection
        @has_access_to_collection[collection] = true
      else
        @has_access_to_collection[collection] = false
      end
    end
  end

  def add_permission
    collection = Collection.find_by(id: params[:collection_id])
    @depositor.collections << collection
    @depositor.save
    redirect_to action: :edit_permissions
  end

  def remove_permission
    collection = Collection.find_by(id: params[:collection_id])
    @depositor.collections.delete(collection)
    @depositor.save
    redirect_to action: :edit_permissions
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_depositor
      @depositor = Depositor.find(params[:id])
    end

    def restrict_to_admin
      redirect_to(depositors_path, notice: "Only admin can perform this action") unless current_user.admin?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def depositor_params
      params.fetch(:depositor, {}).permit(:name,
                                          :basic_authentication_user_id,
                                          :password,
                                          :password_confirmation)
    end
end
