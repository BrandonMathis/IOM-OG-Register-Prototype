# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mimosa-active-registry_session',
  :secret      => '5632bc5060665738cfd9875ccbfffb71aa5824aac8cb23c53ebe5e03449a36c00cc4bc13adb09fd4d8596575b4dbc22d13b7942d8f996cec9dbab0d7906931ab'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
