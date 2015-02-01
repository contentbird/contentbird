#Register factory girl factories to use within cucumber steps
require 'factory_girl'
Dir.glob(File.join(File.dirname(__FILE__), '../../spec/factories.rb')).each {|f| require f }