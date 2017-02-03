class ModifySurveyColumns < ActiveRecord::Migration
  def up
    puts "Fixing surveyor models..."
    ###################
    # Gather all data #
    ####################################################################################
    puts "  Storing survey data..."
    # Remake Surveys
    surveys = Survey.all.to_a
    # Remake SurveySections as Sections
    sections = SurveySection.all.to_a
    # Remake Questions
    questions = Question.all.to_a
    # Remake Answers as Options
    options = Answer.all.to_a
    # Remake ResponseSets as Responses
    response_sets = ResponseSet.all.to_a
    # Remake Responses as QuestionResponses
    responses = Response.all.to_a



    ###################
    # Drop all tables #
    ####################################################################################
    puts "  Dropping tables..."
    drop_table :survey_translations
    drop_table :surveys
    drop_table :survey_sections
    drop_table :question_groups
    drop_table :questions
    drop_table :answers
    drop_table :response_sets
    drop_table :responses



    #######################
    # Recreate all tables #
    ####################################################################################
    puts "  Rebuilding tables..."
    create_table :surveys do |t|
      t.string      :title,         null: false
      t.string      :description
      t.string      :access_code,   null: false
      t.integer     :display_order, null: false
      t.integer     :version,       null: false
      t.boolean     :active,        null: false

      t.timestamps                  null: false
    end
    create_table :sections do |t|
      t.references  :survey,        index: true, foreign_key: true
      t.integer     :display_order, null: false

      t.timestamps                  null: false
    end
    create_table :questions do |t|
      t.references  :section,       index: true, foreign_key: true
      t.text        :content,       null: false
      t.string      :question_type, null: false
      t.string      :description
      t.boolean     :required,      null: false
      
      t.timestamps                  null: false
    end
    create_table :options do |t|
      t.references  :question,  index: true, foreign_key: true
      t.text        :content,   null: false
      
      t.timestamps              null: false
    end
    create_table :responses do |t|
      t.references :survey,               index: true, foreign_key: true
      t.references :identity,             index: true, foreign_key: true
      t.references :sub_service_request,  index: true, foreign_key: true

      t.timestamps                        null: false
    end
    create_table :question_responses do |t|
      t.references  :question,  index: true, foreign_key: true
      t.references  :response,  index: true, foreign_key: true
      t.text        :content,   null: false

      t.timestamps              null: false
    end

    Survey.reset_column_information
    Section.reset_column_information
    Question.reset_column_information
    Option.reset_column_information
    Response.reset_column_information
    QuestionResponse.reset_column_information



    ################
    # Rebuild data #
    ####################################################################################
    puts "  Replacing data..."
    surveys.each do |survey|
      new_survey = Survey.new(
        title:          survey.title,
        description:    survey.description,
        access_code:    survey.access_code,
        display_order:  survey.display_order,
        version:        survey.survey_version,
        active:         true
      )
      new_survey.created_at = survey.created_at
      new_survey.updated_at = survey.updated_at
      new_survey.save(validate: false)

      AssociatedSurvey.where(survey: survey).update_all(survey: new_survey)

      corresponding_question_ids = {}
      sections.select{|s| s.survey_id == survey.id}.each do |section|
        new_section = Section.new(
          survey_id:      new_survey.id,
          display_order:  section.display_order
        )
        new_section.created_at = section.created_at
        new_section.updated_at = section.updated_at
        new_section.save(validate: false)

        questions.select{|q| q.survey_section_id == section.id}.each do |question|
          new_question = Question.new(
            section_id:     new_section.id,
            content:        question.text,
            question_type:  get_question_type(question),
            description:    "",
            required:       question.is_mandatory
          )
          new_question.created_at = question.created_at
          new_question.updated_at = question.updated_at
          new_question.save(validate: false)

          corresponding_question_ids["#{question.id}"] = new_question.id

          options.select{|o| o.question_id == question.id}.each do |option|
            new_option = Option.new(
              question_id:  new_question.id,
              content:      option.text
            )
            new_option.created_at = option.created_at
            new_option.updated_at = option.updated_at
            new_option.save(validate: false)
          end
        end
      end
      
      response_sets.select{|r| r.survey_id == survey.id}.each do |response_set|
        new_response = Response.new(
          survey_id:              new_survey.id,
          identity_id:            response_set.user_id,
          sub_service_request_id: response_set.sub_service_request_id
        )
        new_response.created_at = response_set.created_at
        new_response.updated_at = response_set.updated_at
        new_response.save(validate: false)

        responses.select{|r| r.response_set_id == response_set.id}.each do |response|
          question_response = QuestionResponse.new(
            question_id: corresponding_question_ids["#{response.question_id}"],
            response_id: new_response.id,
            content:     get_question_response_content(options.detect{|a| a.id == response.answer_id}, response)
          )
          question_response.created_at = response.created_at
          question_response.updated_at = response.updated_at
          question_response.save(validate: false)
        end
      end
    end

    puts "Finished fixing surveyor models..."
  end

  def get_question_type(question)
    case question.pick
    when 'one'
      'radio'
    when 'none'
      'text_area'
    else
      ''
    end
  end

  def get_question_response_content(answer, response)
    if answer.present? && answer.text.present?
      answer.text.downcase
    else
      response.text_value.present? ? response.text_value : ''
    end
  end
end
