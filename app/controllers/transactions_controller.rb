class TransactionsController < ApplicationController
  before_action :set_current_book
  before_action :set_transaction, only: :update

  def index
    @transactions = @current_book.transactions.includes(:account, :entity).ordered
    @transaction = @current_book.transactions.new(date: Date.current)
    @accounts = @current_book.accounts.ordered
    @entities = Entity.order(:name)
  end

  def create
    @transaction = @current_book.transactions.new(transaction_params)

    if @transaction.save
      Transaction.recalculate_balances!(@current_book)
      redirect_to transactions_path, notice: "Transaction added."
    else
      load_form_options
      @transactions = @current_book.transactions.includes(:account, :entity).ordered
      render :index, status: :unprocessable_content
    end
  end

  def update
    if @transaction.update(transaction_params)
      Transaction.recalculate_balances!(@current_book)
      redirect_to transactions_path, notice: "Transaction updated."
    else
      load_form_options
      @transactions = @current_book.transactions.includes(:account, :entity).ordered
      @transaction = @current_book.transactions.new(date: Date.current)
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

    def transaction_params
      permitted = params.expect(transaction: [ :date, :number, :entity_id, :payment, :deposit, :account_id, :memo, :reconciled ])
      permitted[:entity_id] = nil if permitted[:entity_id].blank?
      permitted
    end
end
