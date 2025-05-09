class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @home = Home.all
  end

  def new
    @home = Home.new
  end

  def create
    @home = Home.new(home_params)
    @home.user_id = current_user.id

    respond_to do |format|
      if @home.save
        format.html { redirect_to root_path, notice: 'Home was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def home_params
    params.require(:home).permit(:name, :date, :document, :user_id)
  end
end
