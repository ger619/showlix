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

  def show
    @file = Home.find(params[:id])  # Assuming you're using Active Storage and the model is Home
    return unless @file.document.attached?

    # Read the spreadsheet
    spreadsheet = case @file.document.filename.extension
                  when 'csv' then Roo::CSV.new(@file.document.download)
                  when 'xls' then Roo::Excel.new(@file.document.download)
                  when 'xlsx' then Roo::Excelx.new(@file.document.download)
                  end

    # Skip header row if it exists
    header = spreadsheet.row(1)

    # Initialize arrays to store categorized data
    @deposits = []
    @credits = []
    @returns = []

    # Process each row (starting from row 2 to skip header)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      # Assuming your Excel/CSV has a column named 'type' or 'transaction_type'
      # and 'amount' column
      case row['type']&.downcase
      when 'deposit'
        @deposits << row
      when 'credit'
        @credits << row
      when 'return'
        @returns << row
      end
    end

    # Calculate totals
    @total_deposits = @deposits.sum { |d| d['amount'].to_f }
    @total_credits = @credits.sum { |c| c['amount'].to_f }
    @total_returns = @returns.sum { |r| r['amount'].to_f }

  rescue => e
    flash.now[:alert] = "Error processing file: #{e.message}"
    @deposits = []
    @credits = []
    @returns = []
    @total_deposits = 0
    @total_credits = 0
    @total_returns = 0
  end

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
