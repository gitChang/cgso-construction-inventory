class PurchaseOrderReportPdf < Prawn::Document

  def initialize(po)
    super :page_size => "A4", :page_layout => :landscape
    @po = po
    create_report
  end


  def format_amt(amt)
    return amt.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end


  def create_report
    text "PURCHASE ORDER", size: 20, align: :center, font_style: :bold
    move_down 10
    text "City Government of Tagum", size: 12, align: :center, font_style: :underline
    move_down 5
    text "LGU", size: 12, align: :center, font_style: :bold
    move_down 20

    bounds_width_val = bounds.width

    table([
      ["Supplier : #{@po[:supplier]}", "P.O. No. : #{@po[:po_number]}"],
      ["Address : #{@po[:address]}", "Date : #{@po[:date_issued]}"],
      [" ", "Mode of Procurement : #{@po[:mode_of_procurement]}"],
      [" ", "P.R. No. : #{@po[:pr_number]}"],
      [" ", "P.O.W. No. : #{@po[:pow_number]}"]
    ], width: bounds.width, cell_style: { size: 10 })

    move_down 20

    text "REMARKS :  #{@po[:remarks]}", size: 10
    move_down 20

    text "GENTLEMEN :    Please furnish this office the following articles subject to the terms and condition contained herein:", size: 10

    move_down 20
    table([
      ["Place of Delivery : CITY GENERAL SERVICES OFFICE", " "],
      ["Date of Delivery : 7-10 Days upon receipt of P.O.", "Payment Term : After Delivery"]
    ], width: bounds.width, cell_style: { size: 11 })

    move_down 20

    text "PURPOSE :  #{@po[:purpose]}"

    move_down 20

    table( item_rows, width: bounds.width ) do
      style(row(0), font_style: :bold, background_color: 'F3F3F3', align: :center)
      style(column(4..5), align: :right)
      #style(column(10..11), align: :right)

      self.header = true
      self.cell_style = { size: 10 }
    end

    move_down 20

    text "Php #{format_amt('%.2f' % @total_amount)}"

    move_down 20

    text "NOTE : In case of failure to make the full delivery within the time specified above, a penalty of one-tenth (1/10) of one percent for every day of delay shall be imposed. (RULE XXII, Sec. 68, Revise IRR of R.A. 9181)", size: 8
    move_down 20
    text "All Canvass Sheets/Bid Forms were attached to CM'S GEN. MERCHANDISE & CONST'N having the Biggest Amount of Award.", size: 8
    move_down 20

    stroke_horizontal_rule

    move_down 20
    table([
      ['Conforme:', 'Very truly yours,'],
      ["#{@po[:supplier]}", 'ALLAN L. RELLON, DPA, Ph.D'],
      ['(Signature Over Printed Name)', 'City Mayor']
    ], width: bounds.width, cell_style: { size: 10, border_width: 0 }) do
      style(rows(1), font_style: :bold, padding_left: 30)
      style(rows(2), padding_left: 60)
    end
    move_down 20

    stroke_horizontal_rule

    move_down 20
    text "Date: ______________________", size: 9
  end


  def item_rows
    @total_amount = 0.00

    po_items = @po[:po_items].map.with_index do |item, i|
                  @total_amount += item[:amount].to_f
                  [
                    "#{item[:item_number]}.",
                    format_amt(item[:quantity]),
                    item[:unit],
                    item[:name],
                    format_amt(item[:cost]),
                    format_amt(item[:amount])
                  ]
               end

    [[
      "Item", "Quantity", "Unit", "Item Description", "Unit Cost", "Amount"
    ]] + po_items
  end
end