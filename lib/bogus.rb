require 'dependor'
require 'erb'
require 'set'

require_relative 'bogus/takes'
require_relative 'bogus/record_interactions'
require_relative 'bogus/proxies_method_calls'
require_relative 'bogus/rspec_extensions'
require_relative 'bogus/rspec_adapter'

dir = File.realpath File.expand_path('../bogus', __FILE__)
Dir["#{dir}/**/*.rb"].sort.each do |path|
  next if path.include? 'bogus/minitest'
  next if path.include? 'bogus/rspec'
  require path
end

module Bogus
  extend PublicMethods
end
