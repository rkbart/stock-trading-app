require_relative '../config/environment'

require 'factory_bot'

require './spec/support/factory_bot'



puts 'Factory paths: #{FactoryBot.definition_file_paths}'

puts 'Loaded factories: #{FactoryBot.factories.map(&:name)}'


