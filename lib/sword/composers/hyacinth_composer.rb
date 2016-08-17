module Sword
module Composers
class HyacinthComposer

  # takes a DepositContent that was populated via one of the parsers
  # development heuristic: for now, will handle all attributes in DepositContent
  def compose_json(deposit_content, project, digital_object_type)
    data = {}
    data[:digital_object_type] = {string_key: digital_object_type}
    data[:project] = {string_key: project}
    data[:dynamic_field_data] = compose_dynamic_field_data deposit_content
    # puts JSON.generate data
    JSON.generate data
    
  end

  private
  def set_title(sort_portion, non_sort_portion = nil)
    title_data = []
    title_data << { title_non_sort_portion: non_sort_portion, title_sort_portion: sort_portion }
    title_data
  end
  
  def set_abstract(abstract_value)
    # puts abstract_value
    abstract_data = []
    abstract_data << { abstract_value: abstract_value }
    abstract_data
  end

  def set_subject
    # ISSUE!!!!: How do I know which subject category to use? Is it always the same one?
  end

  def set_genre
  end
  
  def compose_dynamic_field_data(deposit_content)
    dynamic_field_data = {}
    dynamic_field_data[:title] = set_title deposit_content.title
    dynamic_field_data[:abstract] = set_abstract deposit_content.abstract
    dynamic_field_data
  end
end
end
end
