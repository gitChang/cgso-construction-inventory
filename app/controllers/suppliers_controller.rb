class SuppliersController < ApplicationController

  def index
    suppliers = []
    query_results = nil
    page = params[:page].present? ? params[:page] : 1

    if params[:name]
      query_results = Supplier.where('lower(name) like ?', "%#{params[:name]}%")
                              .order(created_at: :desc)
    else
      query_results = Supplier.order(updated_at: :desc)
    end

    query_results = query_results.paginate(page: page, per_page: 8)

    suppliers = query_results.collect do |supplier|
                                {
                                  id: supplier.id,
                                  name: supplier.name,
                                  address: supplier.address
                                }
                              end

    render json: Paginator.pagination_attributes(query_results).merge!(suppliers: suppliers)
  end


  def create
    supplier = Supplier.new(name: params[:name], address: params[:address])
    if supplier.save
      render json: true, status: 200
    else
      render json: supplier.errors.first, status: 301
    end
  end


  def show
    supplier = Supplier.where(id: params[:id]).first
    page = params[:page].present? ? params[:page] : 1

    if supplier
      supplier_data = { name: supplier.name, address: supplier.address, total_cost: 0.0, items: [] }
      supplier.purchase_orders.each do |p|
        p.stocks.each do |s|
          supplier_data[:total_cost] += s.cost * s.stock_in
          supplier_data[:items] << {
            poid: s.purchase_order_id,
            po_number: s.purchase_order.po_number,
            item_name: s.item_masterlist.name,
            unit: s.item_masterlist.unit.abbrev,
            supply_type: s.item_masterlist.supply.kind,
            quantity: s.stock_in,
            cost: s.cost
          }
        end
      end
    end

    render json: supplier_data
  end


  def edit
    supplier = Supplier.find(params[:id])
    if supplier
      render json: { name: supplier.name, address: supplier.address }
    else
      render json: {}, status: 404
    end
  end


  def update
    supplier = Supplier.find(params[:id])
    if supplier.update_attributes(name: params[:name], address: params[:address])
      render json: true, status: 200
    else
      render json: supplier.errors.first, status: 301
    end
  end


  def get_names
    render json: Supplier.where('lower(name) like ?', "%#{params[:name]}%")
                         .order(created_at: :desc)
                         .collect { |supplier| supplier.name }
  end


  private

end
