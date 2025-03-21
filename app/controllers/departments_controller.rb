class DepartmentsController < ApplicationController

  def index
    abbrev_param = "%#{params[:abbrev].downcase}%"
    return unless abbrev_param

    departments = Department.select(:abbrev).where('lower(abbrev) like ?', abbrev_param)

    render json: departments.collect { |d| d.abbrev }
  end

  def create
    department = Department.new(name: params[:name], abbrev: params[:abbrev])
    if department.save
      render json: true
    else
      render json: department.errors.first, status: 301
    end
  end
end
