class CustomersController < ApplicationController
  def index
    @customers = Entity.customers.order(:name)
  end

  def new
    @customer = Entity.new(entity_type: :customer, active: true)
  end

  def create
    @customer = Entity.new(customer_params.merge(entity_type: :customer))

    if @customer.save
      redirect_to customers_path, notice: "Customer created."
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    def customer_params
      params.expect(entity: [ :name, :address_line1, :address_line2, :city, :state, :postal_code, :active ])
    end
end
