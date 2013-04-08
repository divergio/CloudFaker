require "sinatra/base"

$read_routes = []

def init_configure
  return [{"route"=>"/b_route/", "response"=>"b response"},{"route"=>"/a_route/", "response"=>"HELLO!!!"}]
end

class Generators
  def initialize
  
  end

  def generate_response
    return Random.rand(2000).to_s()
  end
end

module Gen2
  def test_string
    return "asdf"
  end
end


class MyApp < Sinatra::Base
  helpers Gen2

  configure do
    puts "HELLO2"
    set :generator, Generators.new
    routes = [{"route"=>"/b_route/", "response"=>"b response"},{"route"=>"/a_route/", "response"=>"HELLO!!!"}]
    routes.each do |hash|
      self.get hash["route"] do
        return hash["response"] + settings.generator.generate_response
      end
    end

    set :port, 2000
    puts "I'm here: " + test_string
  end

  get '/' do    

    puts settings.generator
    "Hello from MyApp!" + settings.generator.generate_response + "  " + test_string
  end
  
  run!
end



