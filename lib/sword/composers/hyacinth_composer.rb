module Sword
module Composers
class HyacinthComposer

  # takes a DepositContent that was populated via one of the parsers
  # development heuristic: for now, will handle all attributes in DepositContent
  def compose_json(deposit_content, project, digital_object_type)
    data = {}
    data[:digital_object_type] = {string_key: digital_object_type}
    data[:project] = {string_key: project}
    dynamic_field_data = {}
    dynamic_field_data[:title] = set_title deposit_content.title
    data[:dynamic_field_data] = dynamic_field_data
    # puts JSON.generate data
    JSON.generate data
    
  end

  private
  def set_title(sort_portion, non_sort_portion = nil)
    title_data = []
    title_data << { title_non_sort_portion: non_sort_portion, title_sort_portion: sort_portion }
    # puts title_data
    title_data
  end
end
end
end
