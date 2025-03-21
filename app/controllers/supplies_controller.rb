class SuppliesController < ApplicationController

  def index
    supplies = Supply.all.collect { |supply| supply.kind }
    render json: supplies
  end


  def create
    supply = Supply.new(kind: params[:kind])
    if supply.save
      render json: true
    else
      render json: supply.errors.first, status: 301
    end
  end
end
