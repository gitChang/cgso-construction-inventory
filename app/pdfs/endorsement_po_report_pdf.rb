class EndorsementPoReportPdf < Prawn::Document

  def initialize(letter)
    super :page_size => "FOLIO", :margin => [20,20,20,20]
    @letter = letter
    create_report
  end


  def format_amt(amt)
    return amt.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end


  def create_report
    image_ph_logo = "#{Rails.root}/public/images/philippine-logo.png"
    image_tagum_logo = "#{Rails.root}/public/images/tagum-logo.png"
    image_ew = "#{Rails.root}/public/images/wings-tagumpay.png"

    table([
            [
              { image: image_ph_logo, image_height: 70, image_width: 73 },
              "\nRepublic of the Philippines"\
              "\nProvince of Davao del Norte"\
              "\nCITY GOVERNMENT OF TAGUM"\
              "\n\n<b>CITY GENERAL SERVICES OFFICE</b>",
              { image: image_tagum_logo, image_height: 70, image_width: 73 },
            ]
          ], width: 350, position: :center, cell_style: { inline_format: true, size: 10, border_width: 0, align: :center }) do
      style(row(1), height: 18)
      style(row(2), height: 18)
    end

    #move_down 5
    #text "CITY GENERAL SERVICES OFFICE", align: :center, style: :bold, size: 14

    move_down 15

    text "<b>ENDORSEMENT</b>\n#{@letter[:control_number]}\n#{@letter[:date_endorsed].strftime('%B %-d, %Y')}", inline_format: true, size: 9, align: :center

    #stroke_horizontal_rule
    #move_down 30

    #text "#{@letter[:date_endorsed].strftime('%B %-d, %Y')}", size: 10

    move_down 40

    #text "#{@letter[:recipient][:name]}", style: :bold, size: 10
    #text "#{@letter[:recipient][:designation]}", size: 9
    #text "This City", size: 9

    #move_down 40

    #text "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0THRU: #{@letter[:thru][:name]}", style: :bold, size: 10
    #text "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0#{@letter[:thru][:designation]}", size: 9

    #move_down 50

    #text "Greetings!", size: 10

    #move_down 20

    text "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0Favorably endorsed to <b>MR. #{@letter[:recipient][:name]}</b>, "\
         "#{@letter[:recipient][:designation]}, the herein Stock Card Report of completed infrastructure projects of the city. "\
         "The List are shown in the table below.", inline_format: true, size: 10
    #text "Respecfully submitted herewith the "\
    #     "copies of ACCEPTANCE REPORT, "\
    #     "to wit:", size: 10, align: :center

    move_down 10

    bounds_width_val = bounds.width

    table( collect_pos, width: bounds.width, cell_style: { size: 9, inline_format: true }) do
      style(row(0), font_style: :bold, background_color: 'F3F3F3')
      style(column(0), width: 30)
      style(column(1), width: 80)
      style(column(2), width: 90)
      #style(column(2), width: bounds_width_val - 450)
      style(column(4), width: bounds_width_val - 450, align: :right)
    end

    move_down 20

    text "For your information and reference.", size: 10

    #move_down 50

    #text "Very truly yours,", size: 10

    move_down 40

    text "<b>#{@letter[:sender][:name]}</b>", inline_format: true, size: 10, align: :right
    text "#{@letter[:sender][:designation]}\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0", size: 9, align: :right

    bounding_box [bounds.left, bounds.bottom + 70], :width  => bounds.width do
      stroke_horizontal_rule
      table([[
        "<b>Office Telephone No.</b>: (084) 216 6051\n<b>Email Address</b>: tagum_gso@yahoo.com\n<b>Office Address</b>: Motorpool Service Center, Tipaz St., Magugpo East, Tagum City\n\n#{@letter[:cc]}\n\n<b>Prepared by</b>: #{@letter[:active_user].titleize}",
        { image: image_ew, scale: 0.8, position: :center },
      ]], width: bounds.width, cell_style: { size: 8, border_width: 0, inline_format: true })
    end
  end

  def collect_pos
    selected_pos = @letter[:pos].sort_by{|e| e[:pow_number]}.map.with_index do |item, i|
                          [
                            "#{i + 1}.",
                            "#{item[:po_number]}",
                            "#{item[:pow_number]}",
                            "#{item[:supplier]}",
                            "#{format_amt(item[:total_cost])}"
                          ]
                        end

    [[
      "No.",
      "PO Number",
      "POW / PR Number",
      "Supplier",
      "Total Cost"
    ]] + selected_pos
  end
end
