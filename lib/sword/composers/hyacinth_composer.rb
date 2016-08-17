module Sword
module Composers
class HyacinthComposer
  attr_reader :dynamic_field_data
  def initialize
    @dynamic_field_data = {}
  end

  # takes a DepositContent that was populated via one of the parsers
  # development heuristic: for now, will handle all attributes in DepositContent
  def compose_json(deposit_content, project, digital_object_type)
    data = {}
    data[:digital_object_type] = {string_key: digital_object_type}
    data[:project] = {string_key: project}
    compose_dynamic_field_data deposit_content
    data[:dynamic_field_data] = @dynamic_field_data
    # puts JSON.generate data
    JSON.generate data
  end

  private
  def compose_dynamic_field_data(deposit_content)
    set_title deposit_content.title
    set_abstract deposit_content.abstract
  end

  private
  def set_title(sort_portion, non_sort_portion = nil)
    @dynamic_field_data[:title] = []
    @dynamic_field_data[:title] << { title_non_sort_portion: non_sort_portion, title_sort_portion: sort_portion }
  end
  
  def set_abstract(abstract_value)
    @dynamic_field_data[:abstract] = []
    @dynamic_field_data[:abstract] << { abstract_value: abstract_value }
  end

  def set_subject
    # ISSUE!!!!: How do I know which subject category to use? Is it always the same one?
  end

  def set_genre
  end
end
end
end
