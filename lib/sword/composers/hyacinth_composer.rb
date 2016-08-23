module Sword
module Composers
class HyacinthComposer
  attr_reader :dynamic_field_data
  def initialize(deposit_content, hyacinth_project)
    @deposit_content = deposit_content
    @project = hyacinth_project
    @dynamic_field_data = {}
  end

  # takes a DepositContent that was populated via one of the parsers
  # development heuristic: for now, will handle all attributes in DepositContent
  def compose_json_item
    data = {}
    data[:digital_object_type] = {string_key: 'item'}
    data[:project] = {string_key: @project}
    compose_dynamic_field_data 
    data[:dynamic_field_data] = @dynamic_field_data
    # puts JSON.generate data
    JSON.generate data
  end

  # fcd1, 08/22/16: may not need deposit_content for asset
  # also, may set project in initialize method
  def compose_json_asset(filename, parent_pid)
    data = {}
    data[:digital_object_type] = {string_key: 'asset'}
    data[:project] = {string_key: @project}
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
  def compose_dynamic_field_data
    set_title 
    set_abstract 
  end

  # For now, don't parse out non-sort portion. Can always add functionality later, though
  # need to come up with non-sort terms
  def set_title
    @dynamic_field_data[:title] = []
    @dynamic_field_data[:title] << { title_non_sort_portion: nil,
                                     title_sort_portion:  @deposit_content.title }
  end
  
  def set_abstract
    @dynamic_field_data[:abstract] = []
    @dynamic_field_data[:abstract] << { abstract_value: @deposit_content.abstract }
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
