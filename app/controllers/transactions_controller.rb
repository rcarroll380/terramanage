class TransactionsController < ApplicationController
  before_action :set_current_book
  before_action :set_transaction, only: :update

  def index
    @account = selected_account
    @transactions = transaction_scope.includes(:account, :category_account, :entity).ordered
    @ending_balance = ending_balance
    @accounts = @current_book.accounts.ordered
    @entities = Entity.order(:name)
    @transaction = new_transaction
  end

  def create
    @transaction = @current_book.transactions.new(transaction_params)

    if @transaction.save
      Transaction.recalculate_balances!(@current_book)
      redirect_to transactions_path(account_id: @transaction.account_id), notice: "Transaction added."
    else
      load_form_options
      @transactions = transaction_scope.includes(:account, :category_account, :entity).ordered
      @ending_balance = ending_balance
      render :index, status: :unprocessable_content
    end
  end

  def update
    attributes = transaction_params
    attributes[:account_id] ||= @transaction.account_id

    if @transaction.update(attributes)
      Transaction.recalculate_balances!(@current_book)
      redirect_to transactions_path(account_id: @transaction.account_id), notice: "Transaction updated."
    else
      load_form_options
      @transactions = transaction_scope.includes(:account, :category_account, :entity).ordered
      @ending_balance = ending_balance
      @transaction = new_transaction
      render :index, status: :unprocessable_content
    end
  end

  private
    def set_current_book
      @current_book = Book.find_or_create_by!(name: "My rentals")
    end

    def set_transaction
      @transaction = @current_book.transactions.find(params.expect(:id))
    end

    def load_form_options
      @accounts = @current_book.accounts.ordered
      @entities = Entity.order(:name)
    end

    def new_transaction
      account_id = params[:account_id] if params[:account_id].present? && @accounts.any? { |account| account.id == params[:account_id] }
      account_id ||= @accounts.first&.id
      @current_book.transactions.new(date: Date.current, account_id: account_id)
    end

    def transaction_scope
      scope = @current_book.transactions
      scope = scope.where(account_id: @account.id) if @account
      scope
    end

    def selected_account
      @current_book.accounts.find_by(id: params[:account_id]) if params[:account_id].present?
    end

    def ending_balance
      transaction_scope.order(date: :desc, id: :desc).pick(:balance) || 0
    end

    def transaction_params
      permitted = params.expect(transaction: [ :date, :number, :entity_id, :payment, :deposit, :account_id, :category_account_id, :memo, :reconciled ])
      permitted[:entity_id] = nil if permitted[:entity_id].blank?
      permitted
    end
end
