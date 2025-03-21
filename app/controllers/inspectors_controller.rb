class InspectorsController < ApplicationController

  def index
    inspectors = Inspector.all.collect { |inspector| inspector.name  }
    render json: inspectors
  end
end
