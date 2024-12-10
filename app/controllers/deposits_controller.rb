class DepositsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deposit, only: [:show, :edit, :update, :destroy]
  before_action :restrict_to_admin, only: [:new, :create, :edit, :update, :destroy]

  # GET /deposits
  # GET /deposits.json
  def index
    @deposits = Deposit.all
  end

  # GET /deposits/1
  # GET /deposits/1.json
  def show
  end

  # GET /deposits/new
  def new
    @deposit = Deposit.new
  end

  # GET /deposits/1/edit
  def edit
  end

  # POST /deposits
  # POST /deposits.json
  def create
    @deposit = Deposit.new(deposit_params)

    respond_to do |format|
      if @deposit.save
        format.html { redirect_to @deposit, notice: 'Deposit was successfully created.' }
        format.json { render :show, status: :created, location: @deposit }
      else
        format.html { render :new }
        format.json { render json: @deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deposits/1
  # PATCH/PUT /deposits/1.json
  def update
    respond_to do |format|
      if @deposit.update(deposit_params)
        format.html { redirect_to @deposit, notice: 'Deposit was successfully updated.' }
        format.json { render :show, status: :ok, location: @deposit }
      else
        format.html { render :edit }
        format.json { render json: @deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deposits/1
  # DELETE /deposits/1.json
  def destroy
    @deposit.destroy
    respond_to do |format|
      format.html { redirect_to deposits_url, notice: 'Deposit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_endpoint(collection_slug,
                   depositor_user_id)
    case COLLECTIONS[:slug][collection_slug][:parser]
    when "academic-commons"
      Sword::Endpoints::AcademicCommonsEndpoint.new(collection_slug, depositor_user_id)
    when "proquest"
      Sword::Endpoints::ProquestEndpoint.new(collection_slug, depositor_user_id)
    when "eprints"
      Sword::Endpoints::EprintsEndpoint.new(collection_slug, depositor_user_id)
    else
      # raise an exception here
    end
  end

  def resubmit
    original_deposit = Deposit.find(params[:id])
    endpoint = get_endpoint(original_deposit.collection_slug,
                            original_deposit.depositor_user_id)

    path_to_deposit_contents = original_deposit.content_path

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("About to resubmit deposit for deposit id: #{original_deposit.id}:" \
                      "Collection slug: #{original_deposit.collection_slug}, " \
                      "Username: #{original_deposit.depositor_user_id}, " \
                      "Path to contents: #{path_to_deposit_contents}"
                     )

    endpoint.handle_deposit(path_to_deposit_contents)

    # log basic essential info. Keep it terse! Gonna use :warn level, though not a warning.
    Rails.logger.warn("Following is a re-deposit:" \
                      "Title: #{endpoint.deposit_title.truncate_words(10)}, " \
                      "Files: #{endpoint.documents_to_deposit}, " \
                      "Hyacinth item pid: #{endpoint.adapter_item_identifier}, " \
                      "Hyacinth asset pids: #{endpoint.asset_pids}, " \
                      "Path to SWORD contents: #{path_to_deposit_contents}"
                     )

    # create Deposit instance to store deposit info in database
    resubmit_deposit = Deposit.new
    resubmit_deposit.depositor_user_id = @depositor_user_id
    resubmit_deposit.collection_slug = @collection_slug
    resubmit_deposit.deposit_files = endpoint.documents_to_deposit
    resubmit_deposit.title = "(RE-DEPOSIT) " + original_deposit.title
    resubmit_deposit.item_in_hyacinth = endpoint.adapter_item_identifier
    resubmit_deposit.asset_pids = endpoint.asset_pids
    resubmit_deposit.ingest_confirmed = endpoint.confirm_ingest
    resubmit_deposit.content_path = path_to_deposit_contents
    resubmit_deposit.save
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deposit
      @deposit = Deposit.find(params[:id])
    end

    def restrict_to_admin
      redirect_to(deposits_path, notice: "Only admin can perform this action") unless current_user.admin?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def deposit_params
      params.fetch(:deposit, {}).permit(:title)
    end
end
