require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'
include AcceptanceSpecHelper

RspecApiDocumentation.configure do |config|
  config.format = [:json, :combined_text, :html]
  config.curl_host = 'http://localhost:3000'
  config.api_name = "ClarkCS API"
  
end