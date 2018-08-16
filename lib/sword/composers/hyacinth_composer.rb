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
    set_genre unless @deposit_content.genre_uri.nil?
    set_type_of_resource unless @deposit_content.type_of_resource.nil?
    set_language unless @deposit_content.language_uri.nil?
    set_subjects unless @deposit_content.subjects.nil?
    set_note unless @deposit_content.note.nil?
    set_note_internal unless @deposit_content.note_internal.nil?
    set_deposited_by
    set_embargo_release_date unless @deposit_content.embargo_start_date.nil?
    set_degree_info if (@deposit_content.include_degree_info == true)
    set_date_issued unless @deposit_content.dateIssued.nil?
    set_parent_publication unless @deposit_content.parent_publication_title.nil?
    set_parent_publication_only_doi_uri unless @deposit_content.parent_publication_doi.nil?
    set_use_and_reproduction unless @deposit_content.use_and_reproduction_uri.nil?
    set_license unless @deposit_content.license_uri.nil?
  end

  # For now, don't parse out non-sort portion. Can always add functionality later, though
  # need to come up with non-sort terms
  def set_title
    @dynamic_field_data[:title] = []
    @dynamic_field_data[:title] << { title_non_sort_portion: nil,
                                     title_sort_portion:  @deposit_content.title }
  end

  # use_and_reproduction-1:use_and_reproduction_term.uri.
  def set_use_and_reproduction
    use_and_reproduction_data = { uri: @deposit_content.use_and_reproduction_uri }
    @dynamic_field_data[:use_and_reproduction] = []
    @dynamic_field_data[:use_and_reproduction] << { use_and_reproduction_term: use_and_reproduction_data }
  end

  # license-1:license_term.uri
  def set_license
    license_data = { uri: @deposit_content.license_uri }
    @dynamic_field_data[:license] = []
    @dynamic_field_data[:license] << { license_term: license_data }
  end

  def set_names
    @dynamic_field_data[:name] = []

    # multiple corporate names allowed, deposit_content.corporate_names is an array
    @deposit_content.corporate_names.each do |corporate_name|
      set_corporate_name_and_originator_role corporate_name
    end if @deposit_content.corporate_names

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

  def set_corporate_name_and_originator_role corporate_name
    corporate_name_data = { value: "#{corporate_name}",
                            name_type: 'corporate' }
    name_role_data = []
    name_role_data << set_name_role(METADATA_VALUES[:name_role_originator_value],
                                    METADATA_VALUES[:name_role_originator_uri])
    @dynamic_field_data[:name] << { name_term: corporate_name_data,
                                    name_role: name_role_data }
  end
  
  def set_personal_name_and_author_role author
    value_data = prep_name author
    personal_name_data = { value: value_data,
                           name_type: 'personal' }
    personal_name_data[:uni] = author.uni unless author.uni.nil?
    name_role_data = []
    name_role_data << set_name_role(METADATA_VALUES[:name_role_author_value],
                                    METADATA_VALUES[:name_role_author_uri])
    @dynamic_field_data[:name] << { name_term: personal_name_data,
                                    name_role: name_role_data }
  end
  
   def set_personal_name_and_advisor_role advisor
    value_data = prep_name advisor
    personal_name_data = { value: value_data,
                           name_type: 'personal' }
    name_role_data = []
    name_role_data << set_name_role(METADATA_VALUES[:name_role_thesis_advisor_value],
                                    METADATA_VALUES[:name_role_thesis_advisor_uri])
    @dynamic_field_data[:name] << { name_term: personal_name_data,
                                    name_role: name_role_data }
  end

  def set_name_role(name_role_value, name_role_uri = nil)
    name_role_term_data = { value:  name_role_value }
    name_role_term_data[:uri] = name_role_uri if name_role_uri
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

  def set_note_internal
    @dynamic_field_data[:note] = []
    @dynamic_field_data[:note] << { note_value: @deposit_content.note_internal,
                                    note_type: 'internal' }
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
    @dynamic_field_data[:degree] << { degree_name: @deposit_content.degree_name,
                                      degree_level: 2,
                                      degree_discipline: @deposit_content.corporate_names.first.partition('.').last,
                                      degree_grantor: 'Columbia University' }
  end

  def set_date_issued
    @dynamic_field_data[:date_issued] = []
    @dynamic_field_data[:date_issued] << { date_issued_start_value: @deposit_content.dateIssued }
  end

  def set_parent_publication
    @dynamic_field_data[:parent_publication] = []
    # if this method is being called, there must be an entry in @deposit_content.parent_publication_title
    title_data = []
    title_data << { parent_publication_title_non_sort_portion: nil,
      parent_publication_title_sort_portion:  @deposit_content.parent_publication_title }
    parent_publication_data = { parent_publication_title: title_data }
    parent_publication_data[:parent_publication_date_created_textual] = @deposit_content.pubdate unless @deposit_content.pubdate.nil?
    parent_publication_data[:parent_publication_volume] = @deposit_content.volume unless @deposit_content.volume.nil?
    parent_publication_data[:parent_publication_issue] = @deposit_content.issue unless @deposit_content.issue.nil?
    parent_publication_data[:parent_publication_page_start] = @deposit_content.fpage unless @deposit_content.fpage.nil?
    parent_publication_data[:parent_publication_doi] = @deposit_content.pub_doi unless @deposit_content.pub_doi.nil?
    @dynamic_field_data[:parent_publication] << parent_publication_data
  end

  def set_parent_publication_only_doi_uri
    @dynamic_field_data[:parent_publication] = []
    parent_publication_data = { parent_publication_doi: @deposit_content.parent_publication_doi }
    parent_publication_data[:parent_publication_uri] =
      @deposit_content.parent_publication_uri unless @deposit_content.parent_publication_uri.nil?
    @dynamic_field_data[:parent_publication] << parent_publication_data
  end

  def prep_name person
    if person.full_name_naf_format.nil?
      # Add period to first_name and/or middle_name if name contains only one letter
      prepped_first_name = person.first_name.length == 1 ? person.first_name.slice(0,1) + "." :
        person.first_name unless person.first_name.nil?
      prepped_middle_name = person.middle_name.length == 1 ? person.middle_name.slice(0,1) + "." :
        person.middle_name unless person.middle_name.nil?
      value_data = "#{person.last_name}, #{prepped_first_name} #{prepped_middle_name}"
    else
      value_data = "#{person.full_name_naf_format}"
      # using lookahead, following catches all single letter names and puts
      # a period after them, except for the last one, which does not have
      # a trailing space
      value_data.gsub!( / (\w)(?= )/, ' \1.')
      # Following puts period on last initial, if needed
      value_data.gsub!( /( \w$)/, '\1.')
    end
    value_data
  end

  def set_type_of_resource
    @dynamic_field_data[:type_of_resource] = []
    @dynamic_field_data[:type_of_resource] << { type_of_resource_value: @deposit_content.type_of_resource }
  end
end
end
end
