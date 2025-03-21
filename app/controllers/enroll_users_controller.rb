class EnrollUsersController < ApplicationController

  skip_before_action :require_login, only: [:create]


  def create
    user = User.new(params_user)
    if user.save
      render json: true
    else
      render json: user.errors.first, status: 301
    end
  end


  private

  def params_user
    department_id = get_department_id params[:department]
    department_division_id = get_department_division_id(department_id)
    system_role_id = get_system_role_id params[:system_role]

    params.permit(
      :name,
      :designation,
      :username,
      :password,
      :password_confirmation)
    .merge(
      department_id: department_id,
      department_division_id: department_division_id,
      system_role_id: system_role_id)
  end

end
