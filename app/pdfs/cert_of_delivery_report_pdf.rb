class CertOfDeliveryReportPdf < Prawn::Document

  def initialize(project_data)
    super :page_size => "A4"
    @project_data = project_data
    extracted_items = []
    @project_data[:pos].to_a.each { |i| extracted_items << i }
    @project_data[:pos] = extracted_items
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
            ],
            ['', 'Sitio Tipaz, Magugpo East, Tagum City Philippines', ''],
            ['', 'Tel. Number : 216-6051', '']
          ], width: 350, position: :center, cell_style: { size: 9, border_width: 0, align: :center }) do
      style(row(1), height: 18)
      style(row(2), height: 18)
    end

    move_down 30

    text "CN : #{@project_data[:cert_number]}", align: :right, size: 9

    move_down 50

    text "CERTIFICATION OF DELIVERY", align: :center, size: 16

    move_down 30

    text "This is to certify that the following Purchase Order #{@project_data[:purpose]} (POW Number #{@project_data[:pow_number]}), had been delivered to the GSO-Warehouse, to wit:", size: 11

    move_down 30

    bounds_width_val = bounds.width

    pos = @project_data[:pos].map.with_index do |po, i|
            [
              "#{i + 1}.",
              po[:po_number],
              po[:supplier],
              format_amt(po[:amount]),
              po[:po_date]
            ]
          end

    po_tb = [[
              'No.',
              'P.O. Number',
              'Supplier',
              'Amount',
              'Date Delivered'
          ]] + pos

    table(po_tb, width: bounds.width, cell_style: { size: 9, align: :center }) do
      style(row(0), font_style: :bold)
      style(columns(0), width: bounds_width_val - 485.3)
      style(columns(1), width: bounds_width_val - 420.3)
      style(columns(3), width: bounds_width_val - 450.3, align: :right)

      self.header = true
    end

    move_down 30

    text "This certification is being issued upon the request of #{@project_data[:in_charge]} for any legal purpose it may serve."

    move_down 20

    text "Issued this #{@project_data[:issued_date]} in Tagum City, Davao del Norte, Philippines."

    move_down 50

    img_ew = "#{Rails.root}/public/images/wings-tagumpay.png"

    table([
      ['', '', 'JALMAIDA JAMIRI-MORALES, MPA'],
      ['', '', 'General Services Officer'],
      ['', '', { image: img_ew, image_height: 44 }]
    ], width: bounds.width, cell_style: { border_width: 0 }) do
      style(columns(2), align: :right)
      style(row(1), align: :right, padding_right: 42)
      style(row(2), align: :right, padding_left: 85)
    end
  end
end