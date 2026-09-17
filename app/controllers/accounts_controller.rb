class AccountsController < ApplicationController
  before_action :set_current_book
  before_action :set_account, only: %i[ show edit update destroy ]

  # GET /accounts
  def index
    @accounts = @current_book.accounts.top_level.ordered
  end

  # GET /accounts/1
  def show
  end

  # GET /accounts/new
  def new
    @account = @current_book.accounts.new(active: true)
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  def create
    @account = @current_book.accounts.new(account_params)

    if @account.save
      redirect_to accounts_path, notice: "Account created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: "Account updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /accounts/1
  def destroy
    if @account.destroy
      redirect_to accounts_path, notice: "Account deleted.", status: :see_other
    else
      redirect_to accounts_path, alert: @account.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_current_book
      @current_book = Book.find_or_create_by!(name: "My rentals")
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = @current_book.accounts.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def account_params
      permitted = params.expect(account: [ :parent_id, :account_type, :name, :number, :description, :active ])
      permitted[:parent_id] = nil if permitted[:parent_id].blank?
      permitted
    end
end
