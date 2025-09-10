module V1
  class UsersController < ApplicationController
    before_action :set_user, only: %i[ show update destroy ]

    def index
      @users = User.all
    end

    def show; end

    def create
      @user = User.new(user_params)

      if @user.save
        render :show, status: :created, location: v1_user_url(@user)
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
      end
    end

    def update
      if @user.update(user_params)
        render :show, status: :ok, location: v1_user_url(@user)
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy = @user.destroy!

    private

    def set_user
      @user = User.find(params.expect(:id))
    end

    def user_params = params.expect(user: %i[ name email ])
  end
end
