# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe Person do
  # fixtures :people

  describe 'being created' do
    before do
      @person = nil
      @creating_person = lambda do
        @person = create_unactivated_person
        puts @person.inspect
        violated "#{@person.errors.full_messages.to_sentence}" if @person.new_record?
      end
    end

    it 'increments Person#count' do
      @creating_person.should change(Person, :count).by(1)
    end

    it 'initializes #activation_code' do
      @creating_person.call
      @person.reload
      @person.activation_code.should_not be_nil
    end

    it 'starts in pending state' do
      @creating_person.call
      @person.reload
      @person.should be_pending
    end
  end

  #
  # Validations
  #

  it 'requires login' do
    lambda do
      u = create_unactivated_person(:login => nil)
      u.errors.on(:login).should_not be_nil
    end.should_not change(Person, :count)
  end

  describe 'allows legitimate logins:' do
    ['123', '1234567890_234567890_234567890_234567890', "Iñtërnâtiônàlizætiøn",
     'hello.-_there@funnychar.com'].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_unactivated_person(:login => login_str)
          u.errors.on(:login).should     be_nil
        end.should change(Person, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate logins:' do
    ['12', '1234567890_234567890_234567890_234567890_', "tab\t", "newline\n",
     'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space '].each do |login_str|
      it "'#{login_str}'" do
        lambda do
          u = create_unactivated_person(:login => login_str)
          u.errors.on(:login).should_not be_nil
        end.should_not change(Person, :count)
      end
    end
  end

  it 'requires password' do
    lambda do
      u = create_unactivated_person(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(Person, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_unactivated_person(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(Person, :count)
  end

  it 'requires email' do
    lambda do
      u = create_unactivated_person(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(Person, :count)
  end

  describe 'allows legitimate emails:' do
    ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
     'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
     'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
     'domain@can.haz.many.sub.doma.in', 'student.name@university.edu'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_unactivated_person(:email => email_str)
          u.errors.on(:email).should     be_nil
        end.should change(Person, :count).by(1)
      end
    end
  end
  describe 'disallows illegitimate emails' do
    ['!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
     'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de', "tab\t", "newline\n",
     'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
     # these are technically allowed but not seen in practice:
     'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
    ].each do |email_str|
      it "'#{email_str}'" do
        lambda do
          u = create_unactivated_person(:email => email_str)
          u.errors.on(:email).should_not be_nil
        end.should_not change(Person, :count)
      end
    end
  end

  describe 'allows legitimate names:' do
    ['Andre The Giant (7\'4", 520 lb.) -- has a posse',
     '', '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',
    ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_unactivated_person(:name => name_str)
          u.errors.on(:name).should     be_nil
        end.should change(Person, :count).by(1)
      end
    end
  end
  describe "disallows illegitimate names" do
    ["tab\t", "newline\n",
     '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',
     ].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          u = create_unactivated_person(:name => name_str)
          u.errors.on(:name).should_not be_nil
        end.should_not change(Person, :count)
      end
    end
  end

  it 'resets password' do
    @person = create_activated_person
    @person.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    Person.authenticate(@person.login, 'new password').should == @person
  end

  it 'does not rehash password' do
    @person = create_activated_person(:password => 'monkey', :password_confirmation => 'monkey')
    @person.update_attributes(:login => 'quentin2')
    Person.authenticate('quentin2', 'monkey').should == @person
  end

  #
  # Authentication
  #

  it 'authenticates person' do
    @person = create_activated_person(:password => 'monkey', :password_confirmation => 'monkey')
    Person.authenticate(@person.login, 'monkey').should == @person
  end

  it "doesn't authenticate person with bad password" do
    @person = create_activated_person
    Person.authenticate(@person.login, 'invalid_password').should be_nil
  end

 if REST_AUTH_SITE_KEY.blank?
   # old-school passwords
   it "authenticates a user against a hard-coded old-style password" do
     Person.authenticate('old_password_holder', 'test').should == people(:old_password_holder)
   end
 else
   it "doesn't authenticate a user against a hard-coded old-style password" do
     Person.authenticate('old_password_holder', 'test').should be_nil
   end

   # New installs should bump this up and set REST_AUTH_DIGEST_STRETCHES to give a 10ms encrypt time or so
   desired_encryption_expensiveness_ms = 0.1
   it "takes longer than #{desired_encryption_expensiveness_ms}ms to encrypt a password" do
     test_reps = 100
     start_time = Time.now; test_reps.times{ Person.authenticate('quentin', 'monkey'+rand.to_s) }; end_time   = Time.now
     auth_time_ms = 1000 * (end_time - start_time)/test_reps
     auth_time_ms.should > desired_encryption_expensiveness_ms
   end
 end

  #
  # Authentication
  #
  describe "authentication" do
    before do
      @person = create_activated_person
    end
    
    it 'sets remember token' do
      @person.remember_me
      @person.remember_token.should_not be_nil
      @person.remember_token_expires_at.should_not be_nil
    end

    it 'unsets remember token' do
      @person.remember_me
      @person.remember_token.should_not be_nil
      @person.forget_me
      @person.remember_token.should be_nil
    end

    it 'remembers me for one week' do
      before = 1.week.from_now.utc
      @person.remember_me_for 1.week
      after = 1.week.from_now.utc
      @person.remember_token.should_not be_nil
      @person.remember_token_expires_at.should_not be_nil
      @person.remember_token_expires_at.between?(before, after).should be_true
    end

    it 'remembers me until one week' do
      time = 1.week.from_now.utc
      @person.remember_me_until time
      @person.remember_token.should_not be_nil
      @person.remember_token_expires_at.should_not be_nil
      @person.remember_token_expires_at.should == time
    end

    it 'remembers me default two weeks' do
      before = 2.weeks.from_now.utc
      @person.remember_me
      after = 2.weeks.from_now.utc
      @person.remember_token.should_not be_nil
      @person.remember_token_expires_at.should_not be_nil
      @person.remember_token_expires_at.between?(before, after).should be_true
    end

    it 'registers passive person' do
      person = create_unactivated_person(:password => nil, :password_confirmation => nil)
      person.should be_passive
      person.update_attributes(:password => 'new password', :password_confirmation => 'new password')
      person.register!
      person.should be_pending
    end

    it 'suspends person' do
      @person.suspend!
      @person.should be_suspended
    end

    it 'does not authenticate suspended person' do
      @person = create_activated_person(:password => 'monkey', :password_confirmation => 'monkey')
      @person.suspend!
      Person.authenticate(@person.login, 'monkey').should_not == @person
    end

    it 'deletes person' do
      @person.deleted_at.should be_nil
      @person.delete!
      @person.deleted_at.should_not be_nil
      @person.should be_deleted
    end
  end
  
  describe "being unsuspended" do
    fixtures :people

    before do
      @person = people(:quentin)
      @person.suspend!
    end

    it 'reverts to active state' do
      @person.unsuspend!
      @person.should be_active
    end

    it 'reverts to passive state if activation_code and activated_at are nil' do
      Person.update_all :activation_code => nil, :activated_at => nil
      @person.reload.unsuspend!
      @person.should be_passive
    end

    it 'reverts to pending state if activation_code is set and activated_at is nil' do
      Person.update_all :activation_code => 'foo-bar', :activated_at => nil
      @person.reload.unsuspend!
      @person.should be_pending
    end
  end

end
