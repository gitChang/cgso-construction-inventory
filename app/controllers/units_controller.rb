class UnitsController < ApplicationController

  def index
    if params[:unit]
      render json: Unit.where('abbrev like ? ', "%#{params[:unit]}%").collect { |unit| unit.abbrev }
      return
    end
    render json: Unit.all.collect { |unit| unit.abbrev }
  end


  def create
    unit = Unit.new(name: params[:name], abbrev: params[:abbrev])
    if unit.save
      render json: true
    else
      render json: unit.errors.first, status: 301
    end
  end
end
