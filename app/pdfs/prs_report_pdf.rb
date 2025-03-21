class PrsReportPdf < Prawn::Document

  def initialize(prs)
    super :page_size => "A4"
    @prs = prs
    create_report
  end


  def create_report
    #table([ ["POW No. #{@prs[:pow_number]}", "Control No. #{@prs[:prs_number]}"] ], width: bounds.width, cell_style: { size: 10, border_width: 0, font_style: :bold }) do
    #  style(column(1), align: :right)
    #end

    move_down 10

    text 'PROPERTY RETURN SLIP', align: :center, font_style: :bold

    move_down 30

    table(
      [
        ['Name of Local Government Unit :  CITY GOVERNMENT OF TAGUM'],
        ['Purpose :  (  ) Disposal,  (  ) Repair,  (  ) Returned to Stock,  (  ) Other : _________________________________']
      ], width: bounds.width, cell_style: { size: 9, border_width: 0 }
    )

    move_down 20

    materials = @prs[:materials].map do |m|
                  [
                    m[:quantity],
                    m[:unit],
                    m[:item_description],
                    '',
                    '',
                    '',
                    '',
                    ''
                  ]
                end

    materials_tb = [[
            'Qty.',
            'Unit',
            'Description',
            'Property No.',
            'M.R. No.',
            'Name of End-User',
            'Unit Value',
            'Total'
          ]] + materials

    bounds_width_val = bounds.width

    table(materials_tb, width: bounds.width, cell_style: { size: 9, align: :center }) do
      style(row(0), font_style: :bold)
      style(columns(0), width: bounds_width_val - 485.3)
      style(columns(1), width: bounds_width_val - 485.3)
      style(columns(7), width: bounds_width_val - 485.3)

      self.header = true
    end

    move_down 20

    table( [['Total : ']], width: bounds.width, cell_style: { padding_right: 100, align: :right, border_width: 0 })

    move_down 20

    start_new_page
    stroke_horizontal_rule

    move_down 20

    text 'CERTIFICATION', align: :center

    move_down 20

    foo = [[
      'I HEREBY CERTIFY that I have this _________ day of _____________________, 20_____ RETURNED to:',
      'I HEREBY CERTIFY that I have this _________ day of _____________________, 20_____ RECEIVED from:'
      ],
      ["\n\nWAREHOUSE SECTION -", "\n\n#{@prs[:project_in_charge]}"],
      ["OFFICE OF THE CITY GENERAL SERVICES", "#{@prs[:designation]}"],
      ["-\n_______________________________\n\nthe items/articles described above", "\n_____________________________\n\nthe items/articles described above"],
      ["\n#{@prs[:project_in_charge]}", "\nJALMAIDA JAMIRI-MORALES, MPA"],
      ["#{@prs[:designation]}", "CITY GENERAL SERVICES OFFICER"],
      ["______________________________\n\nDepartment Head\n\n(Name and Signature)", "_____________________________\n\nGeneral Service Office\n\n(Name, Designation and Signature)"
    ]]

    table foo, width: bounds.width, cell_style: { border_width: 0, size: 9, align: :center } do
      style(column(1), borders: [:left], border_width: 1)
      style(row(1).column(1), font_style: :bold)
      style(row(2).column(0), font_style: :bold)
      style(row(4), font_style: :bold)
    end

    pow_string = ""
    pow_string_options = {
      :at => [bounds.right - 800, -2],
      :width => 150,
      :align => :left,
      :size => 9
    }

    page_string = "POW No. #{@prs[:pow_number]} | Ctl. No. #{@prs[:prs_number]} #{"\u00a0" * 100} page <page> of <total>"
    page_string_options = {
      :at => [bounds.right - 600, -10],
      :width => 500,
      :size => 8,
      :align => :right,
      :page_filter => :all,
      :start_count_at => 1
    }

    number_pages page_string, page_string_options
  end
end