module FixtureReplacement
  require 'faker'
  
  attributes_for :person do |a|
    a.login = login_name
    a.name = Faker::Name.name
    a.email = Faker::Internet.email
    pw = FR.random_string(8)
    a.password = pw
    a.password_confirmation = pw
  end
  
  def login_name
    login = ''
    login = Faker::Internet.user_name until login.size > 3 and login.size < 40 and Person.find_by_login(login).blank?
    login
  end
  
end