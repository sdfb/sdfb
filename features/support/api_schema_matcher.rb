RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    schema_directory = "#{Dir.pwd}/features/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, response)
  end
end

RSpec::Matchers.define :strictly_match_response_schema do |schema|
  match do |response|
    schema_directory = "#{Dir.pwd}/features/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, response, strict: true)
  end
end

