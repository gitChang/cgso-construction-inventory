class UserSessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login, except: :destroy
  #skip_before_action :is_spectator, except: :destroy


  def get_user_details
    if current_user
      user = User.find(current_user.id)
      render json: { name: user.name.split(' ').first, designation: user.designation.titleize }
      return
    end
    render json: { name: '', designation: '' }
  end


  def create
    credential = login(params[:username], params[:password])
    if credential
      render json: true, status: 200
      return
    end

    render json: false, status: 301
  end


  def destroy
    logout
    render json: true, status: 200
  end
end
