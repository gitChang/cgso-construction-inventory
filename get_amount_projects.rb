  def format_amt(amt)
    return amt.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end


  def po_complete_delivery_amount
    pos = PurchaseOrder.where("date_issued > '2017-01-01'::date AND date_issued < '2017-09-30'::date AND complete = true")
    amt = 0.00
    n_po = 0
    pos.each do |po|
      n_po += 1
      po.stocks.each do |stock|
        amt += stock.cost * stock.stock_in.to_i
      end
    end

    return "number of pos: #{n_po}, total_amt: #{format_amt(amt)}"
  end


  def issuance_amount
    ris = ReqIssuedSlip.where("date_issued > '2017-01-01'::date AND date_issued < '2017-09-30'::date")
    amt = 0.00
    n_ris = 0
    ris.each do |r|
      n_ris += 1
      r.stocks.each do |stock|
        amt += stock.cost * stock.stock_in.to_i
      end
    end

    return "number of ris: #{n_ris}, total_amt: #{format_amt(amt)}"
  end


  def utilization_amount
    amt = 0.00
    n_proj = 0
    n_endo = 0
    endos = Endorsement.where("created_at > '2017-01-01'::date AND created_at < '2017-09-30'::date")
    endos.each do |endo|
      n_endo += 1
      endo.projects.each do |project|
        n_proj += 1
        project.req_issued_slips.each do |ris|
          ris.stocks.each do |stock|
            amt += stock.cost * stock.stock_in.to_i
          end
        end
      end
    end

    return "num_endos: #{n_endo}, num_proj: #{n_proj}, total_amt: #{format_amt(amt)}"
  end


  def valid_endorsements
    inva = []
    Endorsement.all.each do |e|
      inva << e.id if e.projects.count == 0
    end
    inva
  end
