class SavingsReportPdf < Prawn::Document

  def initialize(savings)
    super :page_size => "LETTER", :page_layout => :landscape, :margin => [30,10,10,10]
    @savings = savings
    create_report
  end


  def format_amt(amt)
    return amt.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end


  def create_report
    text "GSO-WAREHOUSE ITEM SAVINGS REPORT", align: :center

    move_down 10

    text "Construction Materials", align: :center, :size => 12
    move_down 5
    text "As of #{Time.now.strftime("%B %-d, %Y")}", align: :center, :size => 9
    move_down 20

    item_list = Array.new

    @savings.sort_by {|e| e[:item_name] }.map.with_index do |item, i|
      item_list << [
        "#{item[:item_number]}.",
        "#{item[:item_name]}",
        "#{item[:owner]}",
        "#{item[:prs_number]}",
        "#{item[:pow_number]}",
        "#{item[:po_number]}",
        "#{item[:ris_number]}",
        "#{item[:balance]}",
        "#{format_amt(item[:cost])}"
      ]
    end

    item_collection = [[
      "ITEM NO.",
      "DESCRIPTION",
      "OWNER",
      "PRS",
      "POW",
      "PO",
      "RIS",
      "BAL.",
      "COST"
    ]] + item_list

    table(item_collection, width: bounds.width, cell_style: { size: 9 }) do
      style(rows(0), align: :center, font_style: :bold, background_color: 'DDDDDD')
      self.header = true
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