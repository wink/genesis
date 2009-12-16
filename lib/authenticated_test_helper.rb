module AuthenticatedTestHelper
  # Sets the current person in the session from the person fixtures.
  def login_as(person)
    puts person.inspect
    @request.session[:person_id] = person ? (person.is_a?(Person) ? person.id : people(person).id) : nil
  end

  def authorize_as(person)
    @request.env["HTTP_AUTHORIZATION"] = if person 
      person = person.is_a?(Person) ? person : people(person)
      ActionController::HttpAuthentication::Basic.encode_credentials(person.login, 'monkey')
    else
      nil
    end
  end
  
  # rspec
  def mock_person
    person = mock_model(Person, :id => 1,
      :login  => 'user_name',
      :name   => 'U. Surname',
      :to_xml => "Person-in-XML", :to_json => "Person-in-JSON", 
      :errors => [])
    person
  end  
end
