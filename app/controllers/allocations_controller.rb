class AllocationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def show
    allocation_amount = allocation_params[:allocation_amount]
    investor_amounts = allocation_params[:investor_amounts].map(&:to_h)
    allocation = AllocationService.new(allocation_amount:, investor_amounts:)
    allocation.fund!
    render json: allocation.to_h
  end

  private

  def allocation_params
    params.permit(:allocation_amount, investor_amounts: [:name, :requested_amount, :average_amount])
  end
end
