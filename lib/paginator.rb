class Paginator
  class << self
    def pagination_attributes(source_obj, data_hash = {})
      data_hash[:total_entries] = source_obj.total_entries
      previous_page = source_obj.previous_page.present? ? source_obj.previous_page : 0
      data_hash[:current_page] = previous_page+1
      data_hash[:to_index] = (data_hash[:current_page] * source_obj.per_page) > source_obj.total_entries ? source_obj.total_entries : (data_hash[:current_page] * source_obj.per_page)
      data_hash[:from_index] = (previous_page * source_obj.per_page)+1
      data_hash
    end
  end
end