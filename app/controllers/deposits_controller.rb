class DepositsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deposit, only: [:show, :destroy]
  before_action :restrict_to_admin, only: [:destroy]

  # GET /deposits
  # GET /deposits.json
  def index
    @deposits = Deposit.all
  end

  # GET /deposits/1
  # GET /deposits/1.json
  def show
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

  def resubmit
    original_deposit = Deposit.find(params[:id])
    helpers.resubmit_deposit original_deposit
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
