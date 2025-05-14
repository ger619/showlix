class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_home, only: %i[show edit update destroy]
  require 'tempfile'

  def index
    @home = Home.all.order('created_at DESC')
  end

  def new
    @home = Home.new
  end

  def create
    @home = Home.new(home_params)
    @home.user_id = current_user.id

    respond_to do |format|
      if @home.save
        format.html { redirect_to home_path(@home), notice: 'Home was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def show
    @file = Home.find(params[:id])
    return unless @file.document.attached?

    Tempfile.create(['uploaded_file', ".#{@file.document.filename.extension}"]) do |tempfile|
      content = @file.document.download.force_encoding('UTF-8')
      tempfile.write(content)
      tempfile.rewind

      spreadsheet = case @file.document.filename.extension
                    when 'csv' then Roo::CSV.new(tempfile.path)
                    when 'xls' then Roo::Excel.new(tempfile.path)
                    when 'xlsx' then Roo::Excelx.new(tempfile.path)
                    end

      header = spreadsheet.row(1)
      @deposits = []
      @credits = []
      @returns = []

      (2..spreadsheet.last_row).each do |i|
        row = [header, spreadsheet.row(i)].transpose.to_h
        next unless row['type'] && row['amount']

        case row['type']&.strip&.downcase
        when 'deposit'
          @deposits << row
        when 'credit'
          @credits << row
        when 'return'
          @returns << row
        end
      end

      @total_deposits = @deposits.sum { |d| d['amount'].to_f }
      @total_credits = @credits.sum { |c| c['amount'].to_f }
      @total_returns = @returns.sum { |r| r['amount'].to_f }
    end
    # rescue StandardError => e
    # flash.now[:alert] = "Error processing file: #{e.message}"
    # @deposits = []
    # @credits = []
    # @returns = []
    # @total_deposits = 0
    # @total_credits = 0
    # @total_returns = 0
  end

  def edit; end

  def update
    @home.user_id = current_user.id
    respond_to do |format|
      if @home.update(home_params)
        format.html { redirect_to home_path(@home), notice: 'Home was successfully updated.' }
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
