class ItemMasterlistsController < ApplicationController

  def index
    items = []
    query_results = nil
    page = params[:page].present? ? params[:page] : 1

    if params[:name].present?
      query_results = ItemMasterlist.where('name @@ :n', n: params[:name])
    else
      query_results = ItemMasterlist.all.order(:name)
    end

    query_results = query_results.paginate(page: page, per_page: 8)

    items = query_results.collect do |item|
                            {
                              id: item.id,
                              name: item.name,
                              unit: item.unit.abbrev,
                              supplies: item.supply.kind,
                              cost: item.cost,
                              on_hand_count: item.on_hand_count
                            }
                          end

    render json: Paginator.pagination_attributes(query_results).merge!(items: items)
  end


  def create
    item = ItemMasterlist.new(
                  photo_data: params[:photo_data],
                  filename: params[:filename],
                  name: params[:name],
                  name_parameterize: params[:name].parameterize,
                  unit_id: get_units_id(params[:unit]),
                  supply_id: get_supply_id(params[:supply])
                  )
    if item.save
      render json: true, status: 200
    else
      render json: item.errors.first, status: 301
    end
  end


  def edit
    item = ItemMasterlist.find(params[:id])
    if item
      render json: { photo_data: item.photo_data, filename: item.filename, name: item.name, unit: item.unit.abbrev, supply: item.supply.kind }
    else
      render json: {}, status: 404
    end
  end


  def update
    item = ItemMasterlist.find(params[:id])
    if item.update_attributes(
              photo_data: params[:photo_data],
              filename: params[:filename],
              name: params[:name],
              name_parameterize: params[:name].parameterize,
              unit_id: get_units_id(params[:unit]),
              supply_id: get_supply_id(params[:supply])
              )

      render json: true, status: 200
    else
      render json: item.errors.first, status: 301
    end
  end


  def set_on_hand_count
    item = ItemMasterlist.where(id: params[:id]).first

    if item
      item.update_column(:on_hand_count, params[:on_hand_count])
      head :ok
      return
    end
    render json: {}, status: 301
  end


  def get_item_description
    item = ItemMasterlist.where(id: params[:item_id]).first

    if item
      render json: { photo_data: item.photo_data, filename: item.filename, item_description: item.name, unit: item.unit.abbrev, kind: item.supply.kind }
    else
      render json: {}
    end
  end


  def download_items_stock_card_pdf
    item_collection = Array.new

    ItemMasterlist.order(:name).each do |item|
     # update stock_bal column first.
     #item.stocks.where("purchase_order_id IS NOT NULL").each do |source|
     #  source.stocks.each do |depent|
     #    source.update_column(:stock_bal, source.stock_bal - depent.stock_in)
     #  end
     #end

      item_data = Hash.new

      item_data[:article] = item.name.split('-').first.strip
      item_data[:description] = item.name.split('-').drop(1).join('').strip
      item_data[:stock_number] = item.id
      item_data[:unit] = item.unit.abbrev
      item_data[:unit_value] = ""
      #item_data[:balance_per_card] = 0

      #item.stocks.where("purchase_order_id IS NOT NULL AND stock_bal > 0").each do |stock|
      #  next if stock.purchase_order.date_issued.year.to_i != params[:year].to_i
      #  item_data[:balance_per_card] += stock.stock_bal
      #end

      item_collection << item_data #if item_data[:balance_per_card] > 0
    end

    pdf = ItemsStockCardReportPdf.new(item_collection)
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end


  def download_items_stock_card_on_hand_pdf
    item_collection = Array.new

    ItemMasterlist.where('on_hand_count IS NOT NULL AND on_hand_count > 0').order(:name).each do |item|
      item_data = Hash.new

      item_data[:article] = item.name.split('-').first.strip
      item_data[:description] = item.name.split('-').drop(1).join('').strip
      item_data[:stock_number] = item.id
      item_data[:unit] = item.unit.abbrev
      item_data[:unit_value] = ''
      item_data[:balance_per_card] = item.on_hand_count

      item.stocks.where("purchase_order_id IS NOT NULL").order(:created_at).each do |stock|
        next if stock.purchase_order.date_issued.year.to_i != (params[:year].to_i ||  Time.now.year)
        item_data[:unit_value] = stock.cost
      end

      item_collection << item_data
    end

    pdf = ItemsStockCardReportOnHandPdf.new(item_collection)
    send_data pdf.render, type: 'application/pdf', disposition: 'inline'
  end


  private

end
