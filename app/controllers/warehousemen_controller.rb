class WarehousemenController < ApplicationController

  def index
    warehousemen = Warehouseman.all.collect { |warehouseman| warehouseman.name  }
    warehousemen = warehousemen - ['AUTO']
    render json: warehousemen
  end
end
