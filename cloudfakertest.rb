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

  #I realize this isn't ideal testing practice, but it is useful.
  #This will at least give us high confidence that the random generator is operating within parameters
  def test_simple_object
    10.times do
      get '/test/simple_object/'
      unless last_response.ok?
        assert false, "missing success"
      else
        simple_object = JSON.parse(last_response.body)["success"]
        assert_not_nil simple_object["id"], "id on simple object nil"
        assert simple_object["price"] >= 0, "price less than 0"
        assert simple_object["price"] <= 200, "price greater 200"  
      end
    end
  end

  def test_simple_object_five
    get '/test/simple_object/five/'
    
    unless last_response.ok?
      assert false, "missing success"
    else
      simple_object = JSON.parse(last_response.body)["success"]
      assert simple_object.length == 5, "incorrect number of objects returned"
    end
  end
  
  def test_simple_object_range_customization
    10.times() do 
      get '/test/simple_object/range/'

      unless last_response.ok?
        assert false, "missing success"
      else
        simple_object = JSON.parse(last_response.body)["success"]
        assert simple_object.length >= 6 , "too few objects"
        assert simple_object.length <= 10, "too many objects"
      end
    end
  end

  def test_simple_object_generator_customization
    10.times() do
      get '/test/simple_object/customization/'
      
      unless last_response.ok?
        assert false, "Bad response for customization"
      else                                                                                                                
        simple_object = JSON.parse(last_response.body)["success"]                                                         
        assert simple_object["price"] >= 9000, "price less than 9000"
        assert simple_object["price"] <= 9010, "price greater 9010"  
      end                                                                                                                 
    end   
  end

  def test_compound_object
    assert false, "compound object fail"
  end

  def test_compound_object_with_customization
   assert false, "compound object fail"
  end

  def test_compound_object_with_customization_variable_number
    assert false, "compound object fail"
  end

  def test_compound_object_with_count
    assert false, "compound object fail"
  end

  def test_compound_object_with_customization_from_variable
    assert false, "compound object with customization"
  end

end
