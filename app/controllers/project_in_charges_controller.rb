class ProjectInChargesController < ApplicationController

  before_action :init_project_in_charge, only: :create
  before_action :validate_project_in_charge, only: :create


  def index
    in_charges = ProjectInCharge.order(:name).collect { |in_charge| in_charge.name }

    if params[:name]
      in_charges = ProjectInCharge.where('name LIKE ?', "%#{params[:name].upcase}%")
                                  .collect { |in_charge| in_charge.name }
    end

    render json: in_charges
  end


  def create
    render json: true, status: 200 if @project_in_charge.save
  end


  def get_designation
    project = ProjectInCharge.find_by_name(params[:name])

    if project
      render json: { designation: project.designation }, status: 200
      return
    end

    render json: [], status: 200
  end


  private


  def init_project_in_charge
    @project_in_charge = ProjectInCharge.new(
                           #department_id: get_department_id,
                           name: params[:name],
                           designation: params[:designation]
                         )
  end


  def validate_project_in_charge
    render json: @project_in_charge.errors.first, status: 301 if @project_in_charge.invalid?
  end

end
