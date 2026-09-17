class CustomersController < ApplicationController
  def index
    @customers = Entity.customers.order(:name)
  end
end
