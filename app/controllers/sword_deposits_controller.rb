class SwordDepositsController < ApplicationController
  before_action :set_sword_deposit, only: [:show, :edit, :update, :destroy]

  # GET /sword_deposits
  # GET /sword_deposits.json
  def index
    @sword_deposits = SwordDeposit.all
  end

  # GET /sword_deposits/1
  # GET /sword_deposits/1.json
  def show
  end

  # GET /sword_deposits/new
  def new
    @sword_deposit = SwordDeposit.new
  end

  # GET /sword_deposits/1/edit
  def edit
  end

  # POST /sword_deposits
  # POST /sword_deposits.json
  def create
    @sword_deposit = SwordDeposit.new(sword_deposit_params)

    respond_to do |format|
      if @sword_deposit.save
        format.html { redirect_to @sword_deposit, notice: 'Sword deposit was successfully created.' }
        format.json { render :show, status: :created, location: @sword_deposit }
      else
        format.html { render :new }
        format.json { render json: @sword_deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sword_deposits/1
  # PATCH/PUT /sword_deposits/1.json
  def update
    respond_to do |format|
      if @sword_deposit.update(sword_deposit_params)
        format.html { redirect_to @sword_deposit, notice: 'Sword deposit was successfully updated.' }
        format.json { render :show, status: :ok, location: @sword_deposit }
      else
        format.html { render :edit }
        format.json { render json: @sword_deposit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sword_deposits/1
  # DELETE /sword_deposits/1.json
  def destroy
    @sword_deposit.destroy
    respond_to do |format|
      format.html { redirect_to sword_deposits_url, notice: 'Sword deposit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sword_deposit
      @sword_deposit = SwordDeposit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sword_deposit_params
      params.fetch(:sword_deposit, {}).permit(:title)
    end
end
