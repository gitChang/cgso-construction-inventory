class EndorsementCeoReportPdf < Prawn::Document

  def initialize(letter)
    super :page_size => "LEGAL", :margin => [20,20,20,20]
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

    move_down 15
    #text "#{@letter[:control_number]}", align: :right, size: 10, inline_format: true
    text "0001", align: :right, size: 10, inline_format: true

    stroke_horizontal_rule
    move_down 30

    #text "#{@letter[:date_endorsed].strftime('%B %-d, %Y')}", size: 10
    text "#{Time.now.strftime('%B %-d, %Y')}", size: 10

    move_down 40

    #text "#{@letter[:recipient][:name]}", style: :bold, size: 10
    #text "#{@letter[:recipient][:designation]}", size: 9
    #text "This City", size: 9

    move_down 40

    #text "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0THRU: #{@letter[:thru][:name]}", style: :bold, size: 10
    #text "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0#{@letter[:thru][:designation]}", size: 9

    move_down 50

    text "Greetings!", size: 10

    move_down 20

    text "Respecfully submitted the herein Certificate of Completion and Acceptance of various projects in this City as requisite in the preparation of the Summary of Supplies Issued (SSMI) for Construction Materials for completed projects of the City to wit:", size: 10

    move_down 10

    bounds_width_val = bounds.width

    table( collect_projects, width: bounds.width, cell_style: { size: 9, inline_format: true }) do
      style(column(0), width: 30)
      #style(column(1), width: bounds_width_val - 450)
      style(column(1), width: bounds_width_val - 500)
      style(column(3), width: bounds_width_val - 500)
      style(column(5), width: bounds_width_val - 500, align: :right)
      style(column(6), width: bounds_width_val - 500)
      style(row(0), align: :center)
    end

    move_down 20

    text "For your information and reference.", size: 10

    move_down 50

    text "Very truly yours,", size: 10

    move_down 40

    #text "#{@letter[:sender][:name]}", style: :bold, size: 10
    #text "\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0#{@letter[:sender][:designation]}", size: 9

    bounding_box [bounds.left, bounds.bottom + 70], :width  => bounds.width do
      stroke_horizontal_rule
      table([[
#        "<b>Office Telephone No.</b>: (084) 216 6051\n<b>Email Address</b>: tagum_gso@yahoo.com\n<b>Office Address</b>: Motorpool Service Center, Tipaz St., Magugpo East, Tagum City\n\n#{@letter[:cc]}\n\n<b>Prepared by</b>: #{@letter[:active_user].titleize}",
        { image: image_ew, scale: 0.8, position: :center },
      ]], width: bounds.width, cell_style: { size: 8, border_width: 0, inline_format: true })
    end
  end

  def collect_projects
    #selected_projects = @letter[:projects].sort_by{|e| e[:pow_number]}.map.with_index do |item, i|
    #                      [
    #                        "#{i + 1}.",
    #                        "#{item[:date_endorsed].strftime('%B %-d, %Y')}",
    #                        "#{item[:cca_no]}",
    #                        "#{item[:pow_number]}",
    #                        "#{item[:purpose]}.",
    #                        "#{format_amt(item[:total_cost])}",
    #                        "#{item[:date_completed].strftime('%B %-d, %Y')}"
    #                      ]
    #                    end
    selected_projects = [
      [
        "1.",
        "24-Mar-2017\n25-Jul-2017\n13-Mar-2017\n14-Aug-2017",
        "071-17",
        "188-05-16a\n188-05-16b",
        "CONST'N. / COMPLETION OF MULTI-PURPOSE BLDG. LA FILIPINA",
        "1,000.00",
        "15-Jan-2017"
      ],
      [
        "2.",
        "24-Mar-2017\n25-Jul-2017\n13-Mar-2017\n14-Aug-2017",
        "071-17",
        "188-05-16a\n188-05-16b",
        "CONST'N. / COMPLETION OF MULTI-PURPOSE BLDG. LA FILIPINA",
        "2,000.00",
        "15-Jan-2017"
      ]
  ]

    [[
      "<b>NO.</b>",
      "<b>DATE ENDORSED<br>/ACCTG.</b>",
      "<b>CCA NO.</b>",
      "<b>POW REF. NO.</b>",
      "<b>PROJECT NAME AND LOCATION</b>",
      "<b>PROJECT COST</b>",
      "<b>DATE COMPLETED</b>"
    ]] + selected_projects
  end


  def get_projects_po(pown)
    projects_po_coll = Array.new

    unless pown.present?
      return projects_po_coll
    end

    project = Project.where("pow_number = ? OR pr_number = ?", pown, pown).first
    project.purchase_orders.each { |po| projects_po_coll << po.po_number }

    projects_po_coll.join(', ')
  end
end
