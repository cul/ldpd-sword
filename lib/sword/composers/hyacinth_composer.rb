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
    # puts "!!!!!!!!!!!!!!!!!!inside compose_json_item, here is the JSON data!!!!!!!!!!!!!!"
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
    set_name
    set_abstract
    set_note
  end

  # For now, don't parse out non-sort portion. Can always add functionality later, though
  # need to come up with non-sort terms
  def set_title
    @dynamic_field_data[:title] = []
    @dynamic_field_data[:title] << { title_non_sort_portion: nil,
                                     title_sort_portion:  @deposit_content.title }
  end

  def set_name
    @dynamic_field_data[:name] = []

    # only one corporate name
    set_corporate_name_and_originator_role if @deposit_content.corporate_name

    # multiple authors allowed, deposit_content.authors is an array of
    # Deposit::Person
    @deposit_content.authors.each do |author|
      set_personal_name_and_author_role author
    end if @deposit_content.authors

    # multiple advisors allowed, deposit_content.advisors is an array of
    # Deposit::Person
    @deposit_content.advisors.each do |advisor|
      set_personal_name_and_advisor_role advisor
    end if @deposit_content.advisors

    # puts "!!!!!!!!!!!! dynamic_field_data after set_name is done !!!!!!!!!!!"
    # puts @dynamic_field_data[:name].inspect
  end

  def set_corporate_name_and_originator_role
    corporate_name_data = { value: @deposit_content.corporate_name,
                            name_type: 'corporate' }
    name_role_data = []
    name_role_data << set_name_role('originator')
    @dynamic_field_data[:name] << { name_term: corporate_name_data,
                                    name_role: name_role_data }
  end
  
  def set_personal_name_and_author_role author
    value_data = "#{author.last_name}, #{author.first_name} #{author.middle_name}"
    personal_name_data = { value: value_data,
                           name_type: 'personal' }
    name_role_data = []
    name_role_data << set_name_role('author')
    @dynamic_field_data[:name] << { name_term: personal_name_data,
                                    name_role: name_role_data }
  end
  
  def set_personal_name_and_advisor_role advisor
    value_data = "#{advisor.last_name}, #{advisor.first_name} #{advisor.middle_name}"
    personal_name_data = { value: value_data,
                           name_type: 'personal' }
    name_role_data = []
    name_role_data << set_name_role('advisor')
    @dynamic_field_data[:name] << { name_term: personal_name_data,
                                    name_role: name_role_data }
  end
  
  def set_name_role role
    name_role_term_data = { value: role }
    { name_role_term: name_role_term_data }
  end
  
  def set_abstract
    @dynamic_field_data[:abstract] = []
    @dynamic_field_data[:abstract] << { abstract_value: @deposit_content.abstract }
  end

  def set_subject
    # ISSUE!!!!: How do I know which subject category to use? Is it always the same one?
  end

  # Currently, DepositContent contains only one note. In Hyacinth, note is a repeatable field,
  # in case DepositContent contains multiple notes in the future. However, for now, the following
  # code will assume just one note, contained in DepositContent.note
  def set_note
    @dynamic_field_data[:note] = []
    @dynamic_field_data[:note] << { note_value: @deposit_content.note }
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
