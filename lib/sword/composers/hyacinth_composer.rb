module Sword
module Composers
class HyacinthComposer
  attr_reader :dynamic_field_data
  def initialize(deposit_content,
                 hyacinth_project,
                 depositor_name)
    @deposit_content = deposit_content
    @project = hyacinth_project
    @deposited_by = depositor_name
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
    JSON.generate data
  end

  # fcd1, 08/22/16: may not need deposit_content for asset
  # also, may set project in initialize method
  def compose_json_asset(filepath, parent_pid)
    data = {}
    data[:digital_object_type] = {string_key: 'asset'}
    data[:project] = {string_key: @project}
    data[:parent_digital_objects] = [{identifier: parent_pid}]
    data[:import_file] = compose_import_file_data filepath
    Rails.logger.info "!!!!!!!!!!!!!!!!!! import_file!!!!!!!!"
    Rails.logger.info "#{data[:import_file]}"

    # fcd1, 08/22/16: Currently, do not add metadata to asset
    # if this is needed, the following lines can be uncommented
    # compose_dynamic_field_data deposit_content
    # data[:dynamic_field_data] = @dynamic_field_data
    JSON.generate data
  end

  private
  def compose_dynamic_field_data
    set_title 
    set_names
    set_abstract
    set_genre
    set_language
    set_subjects
    set_note
    set_deposited_by
    set_embargo_release_date unless @deposit_content.embargo_start_date.nil?
    set_degree_info unless @deposit_content.corporate_name.nil?
  end

  # For now, don't parse out non-sort portion. Can always add functionality later, though
  # need to come up with non-sort terms
  def set_title
    @dynamic_field_data[:title] = []
    @dynamic_field_data[:title] << { title_non_sort_portion: nil,
                                     title_sort_portion:  @deposit_content.title }
  end

  def set_names
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

  def set_genre
    genre_data = { value: @deposit_content.genre_value,
                   uri: @deposit_content.genre_uri }
    @dynamic_field_data[:genre] = []
    @dynamic_field_data[:genre] << { genre_term: genre_data }
  end

  def set_language
    language_data = { value: @deposit_content.language_value,
                      uri: @deposit_content.language_uri }
    @dynamic_field_data[:language] = []
    @dynamic_field_data[:language] << { language_term: language_data }
  end

  def set_note
    @dynamic_field_data[:note] = []
    @dynamic_field_data[:note] << { note_value: @deposit_content.note }
  end

  def set_subject_topic(topic_value, topic_uri = nil)
    subject_topic_term_data = { value:  topic_value }
    subject_topic_term_data[:uri] = topic_uri if topic_uri
    @dynamic_field_data[:subject_topic] << { subject_topic_term: subject_topic_term_data }
  end

  def set_subject_geographic(geographic_value, geographic_uri = nil)
    subject_geographic_term_data = { value:  geographic_value }
    subject_geographic_term_data[:uri] = geographic_uri if geographic_uri
    @dynamic_field_data[:subject_geographic] << { subject_geographic_term: subject_geographic_term_data }
  end

  def set_subjects
    @dynamic_field_data[:subject_topic] = []
    @dynamic_field_data[:subject_geographic] = []

    # multiple subjects allowed, deposit_content.subjects is an array
    @deposit_content.subjects.each do |subject|
      # hash will return nil if key not present
      proquest_fast_mapping = PROQUEST_FAST_MAP[subject.downcase]
      if proquest_fast_mapping
        fast_subject proquest_fast_mapping
      else
        set_subject_topic subject
      end
    end if @deposit_content.subjects
  end

  def compose_import_file_data(filepath)
    import_file_data = {}
    import_file_data[:import_path]=filepath
    import_file_data[:import_type]='upload_directory'
    import_file_data
  end

  def fast_subject proquest_fast_mapping
    # handle fast topic subjects
    proquest_fast_mapping[:topic].each do |fast_topic|
      set_subject_topic(fast_topic[:label],
                        fast_topic[:uri])
    end if proquest_fast_mapping[:topic]
    # handle fast geographic subjects
    proquest_fast_mapping[:geographic].each do |fast_geographic|
      set_subject_geographic(fast_geographic[:label],
                             fast_geographic[:uri])
    end if proquest_fast_mapping[:geographic]
  end

  def set_deposited_by
    @dynamic_field_data[:deposited_by] = []
    @dynamic_field_data[:deposited_by] << { deposited_by_value: @deposited_by }
  end

  def set_embargo_release_date
    @dynamic_field_data[:embargo_release_date] = []
    @dynamic_field_data[:embargo_release_date] << { embargo_release_date_value: @deposit_content.embargo_release_date }
  end

  def set_degree_info
    @dynamic_field_data[:degree] = []
    @dynamic_field_data[:degree] << { degree_name: 'PHD',
                                      degree_level: 2,
                                      degree_discipline: @deposit_content.corporate_name.partition('.').last,
                                      degree_grantor: 'Columbia University' }
  end
end
end
end
