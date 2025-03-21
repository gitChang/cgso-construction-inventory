class DepartmentDivisionsController < ApplicationController

  def index
    unless params[:department]
      render json: []
      return
    end

    department = Department.find_by_abbrev(params[:department])
    divisions = department.department_divisions
    array_divisions = divisions.collect { |d| d.division }

    render json: array_divisions
  end
end
