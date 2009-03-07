# This test suite tests versioning with Single Table Inheritance

require File.join( File.dirname(__FILE__), '..', 'test_helper' )
require 'active_record'

begin
  require 'globalize/model/active_record'
rescue MissingSourceFile
  puts "This plugin requires the Globalize2 plugin: http://github.com/joshmh/globalize2/tree/master"
  puts
  raise
end

require 'globalize2_versioning'

# Hook up model translation
ActiveRecord::Base.send :include, Globalize::Model::ActiveRecord::Translated
ActiveRecord::Base.send :include, Globalize::Model::ActiveRecord::Versioned

# Load Section model
require File.join( File.dirname(__FILE__), '..', 'data', 'post' )

class PublishingTest < ActiveSupport::TestCase
  def setup
    I18n.fallbacks.clear 
    reset_db! File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'schema.rb'))
    I18n.locale = :en
  end

  test 'publish!' do
    section = Section.create :content => 'foo'
    section.reload
    assert_equal nil, section.content
    section.publish!
    assert_equal 'foo', section.content
    
    section.update_attribute :content, 'bar'                  
    section.reload
    assert_equal 'foo', section.content
    section.publish!
    assert_equal 'bar', section.content
  end                                   

  test 'publish_version' do
    section = Section.create :content => 'foo'
    section.update_attribute :content, 'bar'                  
    section.update_attribute :content, 'baz'                  

    section.reload

    section.publish_version(1)
    assert_equal 'foo', section.content
    
    section.publish_version(3)
    assert_equal 'baz', section.content
    
    section.publish_version(2)
    assert_equal 'bar', section.content
  end
end