class ItemsStockCardReportPdf < Prawn::Document

  def initialize(items)
    super :page_size => "A4", :page_layout => :landscape, :margin => [10,10,10,10]
    @items = items
    create_report
  end


  def format_amt(amt)
    return amt.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end


  def create_report
    image_ph_logo = "#{Rails.root}/public/images/philippine-logo.png"
    image_tagum_logo = "#{Rails.root}/public/images/tagum-logo.png"

    table([
            [
              { image: image_ph_logo, image_height: 60, image_width: 63 },
              "Republic of the Philippines\nProvince of Davao del Norte\nCity of Tagum\n\nOFFICE OF THE CITY GENERAL SERVICES",
              { image: image_tagum_logo, image_height: 60, image_width: 63 },
            ]
          ], width: 350, position: :center, cell_style: { size: 9, border_width: 0, align: :center })

    move_down 30

    text "REPORT ON THE PHYSICAL COUNT OF INVENTORIES", align: :center

    move_down 10

    text "Construction Materials", align: :center, :size => 12
    move_down 5
    text "As of #{Time.now.strftime("%B %-d, %Y")}", align: :center, :size => 9
    move_down 10
    text "For which, <b>Jalmaida Jamiri-Morales, MPA</b>, <b>General Services Officer</b>, <b>Tagum City</b> is accountable, having assumed such accountability on <b>July 1, 2015</b>.", :size => 10, align: :center, inline_format: true

    move_down 30

    bounds_width_val = bounds.width

    item_list = Array.new

    @items.map.with_index do |item, i|
      item_list << [
        "#{i + 1}.",
        "#{item[:article]}",
        "#{item[:description]}",
        "#{item[:stock_number]}",
        "#{item[:unit]}",
        "#{item[:unit_value]}",
        "#{format_amt(item[:balance_per_card])}",
        "",
        "",
        "",
        ""
      ]
    end

    item_collection = [[
      "NO.",
      "ARTICLE",
      "DESCRIPTION",
      "STOCK NUMBER",
      "UNIT OF MEASURE",
      "UNIT VALUE",
      "BALANCE PER CARD",
      "ON HAND PER COUNT",
      "QUANTITY",
      "VALUE",
      "REMARKS"
    ]] + item_list

    table(item_collection, width: bounds.width, cell_style: { size: 8 }) do
      style(column(0), width: bounds_width_val - 790)
      style(column(5), align: :right)
      style(columns(3..10), width: bounds_width_val - 760)
      style(column(8), align: :right)
      style(rows(0), align: :center, font_style: :bold, background_color: 'DDDDDD')

      self.header = true
    end

    signatories = [[
      "<b>Certified by:</b>",
      "<b>Attested by:</b>",
      "<b>Approved by:</b>"
    ]] + [
      [
        "",
        "",
        "",
      ],
      [
        "",
        "",
        "",
      ],
      [
        "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0JALMAIDA JAMIRI-MORALES, MPA",
        "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0ARCELI PANTALEON-GELI",
        "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0ALLAN L. RELLON, DPA, Ph.D"
      ],
      [
        "<b>\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0General Services Officer</b>",
        "<b>\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0State Auditor V</b>",
        "<b>\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0City Mayor</b>"
      ]
    ]

    move_down 70
    table(signatories, width: bounds.width, cell_style: { inline_format: true, border_width: 0, size: 9 }) do
      style(rows(0), size: 10)
      style(rows(2), height: 5)
    end

    options = {
     :at => [bounds.right - 550, 5],
     :width => 150,
     :size => 9,
     :align => :right,
     :page_filter => :all,
     :start_count_at => 1
    }

    number_pages "page <page> of <total>", options
  end
end
