# frozen_string_literal: true

class Sword::Encoders::JsonHyacinth2
  attr_reader :digital_object_data,
              :dynamic_field_data

  attr_accessor :abstract,
                :corporate_names,
                :date_issued,
                :date_issued_start,
                :degree,
                :deposited_by,
                :embargo_release_date,
                :genre_uri,
                :genre_value,
                :hyacinth_project,
                :language_uri,
                :language_value,
                :license_uri,
                :notes,
                :parent_publication,
                :personal_names,
                :subjects,
                :title,
                :type_of_resource,
                :use_and_reproduction_uri

  def initialize
    @dynamic_field_data = {}
    @notes = []
    @corporate_names = []
    @personal_names = []
    @subjects = []
  end

  def compose_dynamic_field_data
    encode_abstract unless @abstract.nil?
    encode_date_issued unless @date_issued_start.nil?
    encode_degree unless @degree.nil?
    encode_deposited_by # this should always be set
    encode_embargo_release_date unless @embargo_release_date.nil?
    encode_genre unless @genre_uri.nil? and @genre_value.nil?
    encode_language unless @language_uri.nil? and @language_value.nil?
    encode_license unless @license_uri.nil?
    encode_names unless (@corporate_names.empty? and @personal_names.empty?)
    encode_notes unless @notes.empty?
    encode_parent_publication unless @parent_publication.nil?
    encode_subjects unless @subjects.empty?
    encode_title # should always be a title, can raise error if so
    encode_type_of_resource unless @type_of_resource.nil?
    unless @use_and_reproduction_uri.nil?
      encode_use_and_reproduction
    else
      encode_use_and_reproduction_default
    end
  end

  def encode_abstract
    @dynamic_field_data[:abstract] = []
    @dynamic_field_data[:abstract] << { abstract_value: @abstract }
  end

  def encode_date_issued
    @dynamic_field_data[:date_issued] = []
    @dynamic_field_data[:date_issued] << { date_issued_start_value: @date_issued_start }
  end

  def encode_degree
    @dynamic_field_data[:degree] = []
    @dynamic_field_data[:degree] << { degree_name: @degree.name,
                                      degree_level: @degree.level,
                                      degree_discipline: @degree.discipline,
                                      degree_grantor: 'Columbia University' }
  end

  def encode_deposited_by
    @dynamic_field_data[:deposited_by] = []
    @dynamic_field_data[:deposited_by] << { deposited_by_value: @deposited_by }
  end

  def compose_internal_format_item
    @digital_object_data = {}
    @digital_object_data[:digital_object_type] = {string_key: 'item'}
    @digital_object_data[:project] = {string_key: @hyacinth_project}
    compose_dynamic_field_data
    @digital_object_data[:dynamic_field_data] = @dynamic_field_data
    @digital_object_data
  end

  def compose_internal_format_asset(parent_pid,
                                    asset_import_filepath)
    @digital_object_data = {}
    @digital_object_data[:digital_object_type] = {string_key: 'asset'}
    @digital_object_data[:project] = {string_key: @hyacinth_project}
    @digital_object_data[:parent_digital_objects] = [{identifier: parent_pid}]
    @digital_object_data[:import_file] = compose_import_file_data asset_import_filepath
    @digital_object_data
  end

  def compose_import_file_data(filepath)
    import_file_data = {}
    import_file_data[:import_path]=filepath
    import_file_data[:import_type]='upload_directory'
    import_file_data
  end

  def encode_embargo_release_date
    @dynamic_field_data[:embargo_release_date] = []
    @dynamic_field_data[:embargo_release_date] << { embargo_release_date_value: @embargo_release_date }
  end

  def encode_genre
    genre_data = { value: @genre_value,
                   uri: @genre_uri }
    @dynamic_field_data[:genre] = []
    @dynamic_field_data[:genre] << { genre_term: genre_data }
  end

  def encode_language
    language_data = { value: @language_value,
                      uri: @language_uri }
    @dynamic_field_data[:language] = []
    @dynamic_field_data[:language] << { language_term: language_data }
  end

  def encode_license
    license_data = { uri: @license_uri }
    @dynamic_field_data[:license] = []
    @dynamic_field_data[:license] << { license_term: license_data }
  end

  def encode_names
    @dynamic_field_data[:name] = []
    encode_corporate_names
    encode_personal_names
  end

  def encode_corporate_names
    @corporate_names.each do |corporate_name|
      set_corporate_name_and_originator_role corporate_name
    end
  end

  def set_corporate_name_and_originator_role corporate_entity
    corporate_name_data = { value: "#{corporate_entity.name}",
                            name_type: 'corporate' }
    name_role_data = []
    name_role_data << set_name_role(METADATA_VALUES[:name_role_originator_value],
                                    METADATA_VALUES[:name_role_originator_uri])
    @dynamic_field_data[:name] << { name_term: corporate_name_data,
                                    name_role: name_role_data }
  end

  def set_name_role(name_role_value, name_role_uri = nil)
    name_role_term_data = { value:  name_role_value }
    name_role_term_data[:uri] = name_role_uri if name_role_uri
    { name_role_term: name_role_term_data }
  end

  def encode_personal_names
    # SWORD-86: here, if upper bound is set on the number of names allowed in Hyacinth ingest, truncate @personal_names
    if HYACINTH_CONFIG.has_key? :max_number_names and @personal_names.length > HYACINTH_CONFIG[:max_number_names]
      @notes << Sword::Metadata::Note.new('SWORD deposit contains more than ' + HYACINTH_CONFIG[:max_number_names].to_s + ' names, only first ' +
                                          HYACINTH_CONFIG[:max_number_names].to_s + ' processed. See mets.xml for full list.' +
                                          ' Large number of Name fields will generate error in Hyacinth. See JIRA ticket SWORD-86.','internal')
      @personal_names = @personal_names[0..HYACINTH_CONFIG[:max_number_names] - 1]
    end
    @personal_names.each do |personal_name|
      case personal_name.role
      when 'author'
        set_personal_name_and_author_role personal_name
      when 'thesis_advisor'
        set_personal_name_and_advisor_role personal_name
      else
        # default to author? (check this)
        set_personal_name_and_author_role personal_name
      end
    end
  end

  def encode_notes
    @dynamic_field_data[:note] = []
    # @notes contains Sword::Metadata::Note instances
    @notes.each do |note|
      @dynamic_field_data[:note] << { note_value: note.content, note_type: note.type }.compact
    end
  end

  def encode_parent_publication
    @dynamic_field_data[:parent_publication] = []
    parent_publication_data = {}

    unless @parent_publication.title.nil?
      title_data = []
      title_data << { parent_publication_title_non_sort_portion: nil,
                      parent_publication_title_sort_portion:  @parent_publication.title }
      parent_publication_data[:parent_publication_title] = title_data
    end
    parent_publication_data[:parent_publication_date_created_textual] =
      @parent_publication.publish_date unless @parent_publication.publish_date.nil?
    parent_publication_data[:parent_publication_volume] =
      @parent_publication.volume unless @parent_publication.volume.nil?
    parent_publication_data[:parent_publication_issue] =
      @parent_publication.issue unless @parent_publication.issue.nil?
    parent_publication_data[:parent_publication_page_start] =
      @parent_publication.start_page unless @parent_publication.start_page.nil?
    parent_publication_data[:parent_publication_doi] =
      @parent_publication.doi unless @parent_publication.doi.nil?
    parent_publication_data[:parent_publication_uri] =
      @parent_publication.uri unless @parent_publication.uri.nil?
    @dynamic_field_data[:parent_publication] << parent_publication_data
  end

  def encode_subjects
    @dynamic_field_data[:subject_topic] = []
    @dynamic_field_data[:subject_geographic] = []

    # multiple subjects allowed, deposit_content.subjects is an array
    @subjects.each do |subject|
      # hash will return nil if key not present
      proquest_fast_mapping = PROQUEST_FAST_MAP[subject.downcase]
      if proquest_fast_mapping
        fast_subject proquest_fast_mapping
      else
        set_subject_topic subject
      end
    end
  end

  def encode_title
    @dynamic_field_data[:title] = []
    @dynamic_field_data[:title] << { title_non_sort_portion: nil,
                                     title_sort_portion:  @title }
  end

  def encode_type_of_resource
    @dynamic_field_data[:type_of_resource] = []
    @dynamic_field_data[:type_of_resource] << { type_of_resource_value: @type_of_resource }
  end

  def encode_use_and_reproduction
    use_and_reproduction_data = { uri: @use_and_reproduction_uri }
    @dynamic_field_data[:use_and_reproduction] = []
    @dynamic_field_data[:use_and_reproduction] << { use_and_reproduction_term: use_and_reproduction_data }
  end

  def encode_use_and_reproduction_default
    use_and_reproduction_data = { uri: 'http://rightsstatements.org/vocab/InC/1.0/',
                                  authority: 'rightsstatements',
                                  value: 'In Copyright'}
    @dynamic_field_data[:use_and_reproduction] = []
    @dynamic_field_data[:use_and_reproduction] << { use_and_reproduction_term: use_and_reproduction_data }
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

  def set_personal_name_and_author_role author
    value_data = prep_name author
    personal_name_data = { value: value_data,
                           name_type: 'personal' }
    name_role_data = []
    name_role_data << set_name_role(METADATA_VALUES[:name_role_author_value],
                                    METADATA_VALUES[:name_role_author_uri])
    @dynamic_field_data[:name] << { name_term: personal_name_data,
                                    name_role: name_role_data }
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
end
