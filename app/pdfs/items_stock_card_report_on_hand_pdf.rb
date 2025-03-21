class ItemsStockCardReportOnHandPdf < Prawn::Document

  def initialize(items)
    super :page_size => "LEGAL", :page_layout => :landscape, :margin => [10,10,10,10]
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
        "#{format_amt(item[:unit_value])}",
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

    move_down 500

    member1 = [[
      "<b>Checked and Inspected By:</b>",
      "<b>Certified Correct By:</b>"
    ]] + [
      [
        "",
        "",
      ],
      [
        "",
        "",
      ],
      [
        "#{"\u00a0" * 12}<b>ROGER J. DOMPOL, MPA</b>",
        "<b>JALMAIDA L. JAMIRI-MORALES, MPA</b>",
        "<b>RAMIL Y. TIU, CPA</b>",
        "<b>EDGAR C. DE GUZMAN</b>"
      ],
      [
        "#{"\u00a0" * 16}Warehouse In-charge",
        "#{"\u00a0" * 12}General Services Officer",
        "#{"\u00a0" * 3}City Accountant",
        "#{"\u00a0" * 6}City Treasurer"
      ],
      [
        "",
        "#{"\u00a0" * 15}Vice Chairperson",
        "#{"\u00a0" * 8}Member",
        "#{"\u00a0" * 10}Member"
      ]
    ]

    move_down 70
    table(member1, width: bounds.width, cell_style: { inline_format: true, border_width: 0, size: 12 }) do
      style(rows(4..5), size: 10)
    end

    member2 = [[
      "",
      "<b>ARCADIA E. YLANAN, CPA</b>",
      "<b>ENGR. ROOSEVELT A. CORPORAL, CE</b>"
    ]] + [
      [
        "",
        "#{"\u00a0" * 8}City Budget Officer",
        "#{"\u00a0" * 12}City Engineer"
      ],
      [
        "",
        "#{"\u00a0" * 12}Member",
        "#{"\u00a0" * 16}Member"
      ]
    ]

    move_down 30
    table(member2, width: bounds.width, cell_style: { inline_format: true, border_width: 0, size: 12 }) do
      style(rows(1..2), size: 10)
      #style(rows(1..2), height: 5)
    end

    member3 = [[
      "",
      "",
      "",
      "#{"\u00a0" * 6}<b>Approved By:</b>",
      ""
    ]] + [
      [
        "",
        "",
        "",
        "",
        ""
      ],
      [
        "",
        "",
        "",
        "#{"\u00a0" * 12}<b>GIOVANNI L. RELLON, MDMG</b>",
        ""
      ],
      [
        "",
        "",
        "",
        "#{"\u00a0" * 24}City Administrator",
        ""
      ],
      [
        "",
        "",
        "",
        "#{"\u00a0" * 24}#{"\u00a0" * 5}Chairman",
        ""
      ]
    ]

    move_down 40
    table(member3, width: bounds.width, cell_style: { inline_format: true, border_width: 0, size: 12 }) do
      style(rows(3..4), size: 10)
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
