# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wecloud_session',
  :secret      => '2f4ae441ab8ece7c98290d2e069a93183753d1ff217706aedef816b95e2938e85cc51f0dacf339a4def04517ccd613e051fdde7a5b22fd671f3b73165b0b2397'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
