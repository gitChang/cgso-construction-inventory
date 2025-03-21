class StocksController < ApplicationController

  def validate_item
    item = Stock.new(
                  pr_number: params[:pr_number],
                  source_stock_id: params[:source_stock_id],
                  item_number: params[:item_number],
                  item_id: params[:item][:id],
                  cost: params[:cost],
                  stock_in: params[:quantity]
                )

    render json: item.errors.first, status: 301 if item.invalid?
    render json: true, status: 200 if item.valid?
  end


  def destroy
    item = Stock.find(params[:id])
    render json: item.destroy if item
  end


  def has_dependents
    item = Stock.find(params[:id])
    if item.stocks.present?
      ris = item.stocks.first.req_issued_slip.ris_number
      render json: { message: "Deleting this PO item has been denied. It has already been issued. See RIS ##{ris}." }
    else
      render json: false
    end
  end


  private

end
