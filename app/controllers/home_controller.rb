class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_home, only: %i[show edit update destroy]

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

  def show; end

  def edit; end

  def update
    @home.user_id = current_user.id
    respond_to do |format|
      if @home.update(home_params)
        format.html { redirect_to root_path, notice: 'Home was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @home.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Home was successfully deleted.' }
    rescue ActiveRecord::RecordNotFound
      format.html { redirect_to root_path, alert: 'Home not found.' }
    end
  end

  private

  def set_home
    @home = Home.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Home not found.'
  end

  def home_params
    params.require(:home).permit(:name, :date, :document, :user_id)
  end
end
