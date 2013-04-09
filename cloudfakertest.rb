require 'test/unit'
require 'rack/test'
require './cloudfaker.rb'
require 'json'

ENV['RACK_ENV'] = 'test'

class CloudFakerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    CloudFaker
  end

  def test_it_says_hello_world
    get '/hello/'
    assert_equal "Hello world", last_response.body
  end
  
  def test_parameter_conditions
    get '/test/param_conditions/', {:requiredValue =>'anything', :fixedValue => 'ThisIsAFixedValue', :constantValue => 'TEST'}
    assert last_response.body.include?("success") 
  end

  def test_parameter_require_something_else
    get '/test/param_conditions/', {:requiredValue => 'another_thing', :fixedValue => 'ThisIsAFixedValue', :constantValue => 'TEST'}
    assert last_response.body.include?("success")
  end

  def test_parameter_require_fail
    get '/test/param_conditions/', {:fixedValue => 'ThisIsAFixedValue', :constantValue => 'TEST'}
    assert last_response.body.include?("failure")
  end

  def test_parameter_fixed_fail
    get '/test/param_conditions/', {:requiredValue => "anything", :fixedValue => 'ThisIsTheWrongFixedValue', :constantValue => 'TEST'}
    assert last_response.body.include?("failure")
  end

  def test_parameter_constant_fail
    get '/test/param_conditions/', {:requiredValue => "anything", :fixedValue => 'ThisIsAFixedValue', :constantValue => 'WrongConstant'}
    assert last_response.body.include?("failure")
  end

  def test_path_conditions
    get '/test/path_conditions/TEST/'
    assert last_response.body.include?("success")
  end

  def test_simple_object
    get '/test/simple_object/'
    
    assert last_response.body.include?("success")
    assert !last_response.body.include?("$") , "$ left in body"
    simple_object = JSON.parse(last_response.body)["success"]
    assert_not_nil simple_object["id"], "id on simple object nil"
    assert simple_object["price"] >= 0, "price less than 0"
    assert simple_object["price"] <= 200, "price greater 200"  
  end

end
