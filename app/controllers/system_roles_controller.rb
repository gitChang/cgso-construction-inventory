class SystemRolesController < ApplicationController

  def index
    system_roles = SystemRole.all.collect { |role| role.role }
    render json: system_roles
  end
end
