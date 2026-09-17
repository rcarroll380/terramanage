class VendorsController < ApplicationController
  before_action :set_vendor, only: %i[ edit update ]

  def index
    @vendors = Entity.vendors.order(:name)
  end

  def new
    @vendor = Entity.new(entity_type: :vendor, active: true)
  end

  def create
    @vendor = Entity.new(vendor_params.merge(entity_type: :vendor))

    if @vendor.save
      redirect_to vendors_path, notice: "Vendor created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @vendor.update(vendor_params)
      redirect_to vendors_path, notice: "Vendor updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_vendor
      @vendor = Entity.vendors.find(params.expect(:id))
    end

    def vendor_params
      params.expect(entity: [ :name, :address_line1, :address_line2, :city, :state, :postal_code, :active ])
    end
end
