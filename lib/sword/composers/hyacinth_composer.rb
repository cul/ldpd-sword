module Sword
module Composers
class HyacinthComposer
  attr_reader :dynamic_field_data
  def initialize
    @dynamic_field_data = {}
  end

  # takes a DepositContent that was populated via one of the parsers
  # development heuristic: for now, will handle all attributes in DepositContent
  def compose_json_item(deposit_content, project)
    data = {}
    data[:digital_object_type] = {string_key: 'item'}
    data[:project] = {string_key: project}
    compose_dynamic_field_data deposit_content
    data[:dynamic_field_data] = @dynamic_field_data
    # puts JSON.generate data
    JSON.generate data
  end

  # fcd1, 08/22/16: may not need deposit_content for asset
  # also, may set project in initialize method
  def compose_json_asset(deposit_content, project, filename, parent_pid)
    data = {}
    data[:digital_object_type] = {string_key: 'asset'}
    data[:project] = {string_key: project}
    data[:parent_digital_objects] = [{identifier: parent_pid}]
    data[:import_file] = compose_import_file_data filename

    # puts data.inspect
    # fcd1, 08/22/16: can add select dynamic fields if needed
    # compose_dynamic_field_data deposit_content
    # data[:dynamic_field_data] = @dynamic_field_data
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

  def compose_import_file_data(filename)
    # puts "!!!!!!!!!!!!!!!!!!!! Filename: #{filename} !!!!!!!!!!!!!!!!!"
    import_file_data = {}
    import_file_data[:import_path]=filename
    import_file_data[:import_type]='upload_directory'
    import_file_data
  end

  def set_genre
  end
end
end
end
