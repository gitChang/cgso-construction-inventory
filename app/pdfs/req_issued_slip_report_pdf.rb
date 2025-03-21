class ReqIssuedSlipReportPdf < Prawn::Document

  def initialize(ris)
    super :page_size => "FOLIO", margin: [10,10,10,10]
    @ris = ris
    create_report
  end


  def format_amt(amt)
    return amt.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end


  def create_report
    text "REQUISITION ISSUED SLIP", size: 12, align: :center, font_style: :bold
    move_down 10
    text "City Government of Tagum", size: 8, align: :center, font_style: :underline
    move_down 5
    text "LGU", size: 8, align: :center, font_style: :bold
    move_down 10

    stroke_horizontal_rule

    move_down 10

    bounds_width_val = bounds.width

    table([
      ['Department', ':', "#{@ris[:department]}", 'RIS No.', ':', "#{@ris[:ris_number]}"],
      ["Division", ':', ' ', 'POW No.', ':', "#{@ris[:pow_number]}"],
      [" ", ' ', ' ', 'Date', ':', "#{@ris[:date_issued]}"]
    ], width: bounds.width, cell_style: { size: 8, border_width: 0, font_style: :bold })

    move_down 10
    stroke_horizontal_rule
    move_down 10

    text "REQUISITION ISSUANCE", align: :center, font_style: :bold, size: 9

    move_down 10

    table( item_rows, width: bounds.width ) do
      style(row(0), font_style: :bold, background_color: 'F3F3F3', align: :center)
      self.header = true
      self.cell_style = { size: 8 }
    end
    move_down 10

    table([['PURPOSE :'], ["#{@ris[:purpose]}"]], width: bounds.width, cell_style: { size: 8, border_width: 0 }) do
      style(rows(0), font_style: :bold)
      style(rows(1), padding_left: 30)
    end

    move_down 10

    table([
      ['Requested by:', 'Approved by:', 'Issued by:', 'Received by:'],
      ['', '', '', ''],
      ["#{@ris[:in_charge]}", "#{@ris[:approved_by].upcase}", "#{@ris[:issued_by].upcase}", "#{@ris[:withdrawn_by].upcase}"],
      ["#{@ris[:in_charge_designation]}", "#{@ris[:approved_by_designation]}", "#{@ris[:issued_by_designation]}", "#{@ris[:withdrawn_by_designation]}"]
    ], width: bounds.width, cell_style: { border_width: 0, size: 9 }) do
      style(rows(1), height: 15)
      style(rows(0..3), height: 20)
      style(rows(2), font_style: :bold)
      style(rows(2..3), align: :center)
      style(rows(3), size: 8)
    end
    move_down 10
    text "Prepared by: #{@ris[:user].titleize} #{"\u00a0" * 6} | #{"\u00a0" * 6} PR No.: #{@ris[:pr_number]}", size: 9
  end


  def item_rows
    @total_amount = 0.00

    ris_items = @ris[:ris_items].map.with_index do |item, i|
                  @total_amount += item[:amount].to_f
                  [
                    "#{item[:item_number]}.",
                    item[:unit],
                    item[:name],
                    item[:quantity],
                    item[:remarks]
                  ]
               end

    [[
      "Item No.", "Unit", "Description", "Quantity", "Remarks"
    ]] + ris_items
  end
end
