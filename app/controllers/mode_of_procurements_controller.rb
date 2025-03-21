class ModeOfProcurementsController < ApplicationController

  def index
    render json: ModeOfProcurement.all.collect { |mode| mode.mode }
  end

  def create
    mode = ModeOfProcurement.new(mode: params[:mode].upcase)
    if mode.save
      render json: true
    else
      render json: mode.errors.first, status: 301
    end
  end
end
