MIMOSA_XMLNS = "http://www.mimosa.org/osa-eai/v3-2/xml/CCOM-ML"
XSI_XMLNS = "http://www.w3.org/2001/XMLSchema-instance"
POSTBACK_HOST = "localhost"
POSTBACK_PORT = "4567"
POSTBACK_PATH = "/CCOMData/ActualEvent"
POSTBACK_URI = "http://#{POSTBACK_HOST}:#{POSTBACK_PORT}#{POSTBACK_PATH}"
APP_VERSION = "2.8.1"

File.open(File.join(RAILS_ROOT, 'config/database.mongoid.yml'), 'r') do |f|
  @settings = YAML.load(f)[RAILS_ENV]
end

CCOM_DATABASE = @settings["ccom_database"]
ROOT_DATABASE = @settings["root_database"]
MONGO_HOST = @settings["host"]