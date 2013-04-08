# API-prototype
# Tyler Barth divergio@gmail.com
# idea from Kenzou Yeh.
#
# Currently it has some structural problems that I haven't been able to solve. 
# I want to move this all to a gem, and just use a commandline script that imports the gem 
# and also takes an argument for the configuration file.
#
# I don't know how to pass in arguments to an instance of Sinatra, though, i.e. CloudFaker.new(foo,bar)
# It seems Sinatra doesn't work that way
# 

require 'sinatra/base'
require 'optparse'
require 'ostruct'
require 'yaml'

def do_something
  puts "doing something"
end

class Generator
  def initialize
  end

  #the default random_pictures method, the links are pretty slow. You can override. 
  def random_pictures
  end

  def test_string
    return "some strings"
  end
end

def parse_options(argv)
  options = {}
  OptionParser.new do |opts|
    options = OpenStruct.new

    #defaults
    options.generator = "./Generator.rb"
    options.port = 8080

    opts.banner = "Usage: cloudfaker.rb [options] rules.yaml"

    opts.on("-g", "--generators [Generator.rb]",
            "File to import containing the Generators subclass. Default is ./Generators.rb") do |gen|
      options.generator = gen;
    end

    opts.on("-p", "--port [Port to run Sinatra on, default 8080]",
            "" ) do |port|
      options.port = port;
    end

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!

  if ARGV.length == 0
    $stderr.puts "Please provide a rules files."
    exit
  elsif ARGV.length > 1
    $stderr.puts "Too many rules files."
    exit
  end

  return options, ARGV
end


module Sinatra
  module CloudFakerHelper
    
    def handle_get(key,value)
      if value["implemented"]
        #Http://stackoverflow.com/questions/11920513/sinatra-app-that-redirects-post-get-requests-with-parameters
        redirect settings.production_server + request.fullpath
      end
      
      
    end
    
    def handle_put(key,value)
      if value["implemented"]
        redirect settings.production_server + request.fullpath, 307
      end
    end
    
    def handle_post(key,value)
      if value["implemented"]
        redirect settings.production_server + request.fullpath, 307
      end
    end
    
    def shared_handle(key,value)
      if value["implemented"]
        
      end
        
    end
    
  end
end

class CloudFaker < Sinatra::Base
  helpers Sinatra::CloudFakerHelper

  def self.establish_routes(routes)
    print "Configuring routes..."
    routes.each do |key, value|
      print "."
      case value["type"]
      when "GET"
        self.get value["path"] do
          return handle_get(key,value)
        end
        
      when "PUT"
        self.put value["path"] do
          return handle_put(key,value)
        end
      
      when "POST"
        self.post value["path"] do
          return handle_post(key,value)
        end
      else
        $stderr.puts "We currently don't handle route types of  #{value["route"]}"
      end
    end
    puts 
  end

  def self.read_configuration(configuration)    
    configuration.each do |key, value|
      case key
      when "PORT"
        set :port, value
      when "PRODUCTION_SERVER"
        set :production_server, value
      end
    end
  end

  configure do
    options, argv = parse_options(ARGV)
    
    #pass the port to Sinatra
    set :port, options.port
    
    #import the generator
    
    #look for a generator subclass in the file
    generator_class = nil
    if File.exist?(options.generator)

      #http://stackoverflow.com/a/5306426/1016515
      #a bit hacky, wish there was a better way
      existing_classes = ObjectSpace.each_object(Class).to_a
      load options.generator
      new_classes = ObjectSpace.each_object(Class).to_a - existing_classes
      non_anonymous_new_classes = new_classes.find_all(&:name)
      
      #get the generator class (if any) in this file
      generator_class = non_anonymous_new_classes.each do |someclass| 
        if someclass <= Generator
          break someclass
        end
      end

      if !generator_class
        $stderr.puts "WARNING: No Generator subclass found in #{options.generator}"
      end
    else
      $stderr.puts "WARNING: Generator file #{options.generator} doesn't exist."
    end

    #Create a generator (use default if no other)
    if !generator_class
      @generator = Generator.new
    else
      @generator = generator_class.new
    end

    set :generator, @generator
    
    #Load the rules files
    #http://stackoverflow.com/a/3877355/1016515
     if File.exist?(argv.first)
       rule_file_stuff = YAML.load_file(argv.first) 
     
       @configuration = rule_file_stuff["Configuration"]       
       constants = rule_file_stuff["Constants"]
       response_objects = rule_file_stuff["Objects"]
       @requests = rule_file_stuff["Requests"]

       set :constants, constants       
       set :response_objects, response_objects

     else
       $stderr.puts "Can't find rules files."
       exit
     end

    #Actually setup the rules
    establish_routes(@requests)
    #configure the ports/server addresses
    read_configuration(@configuration)

  end
  

  get "/static/" do
    "static" + params.to_s()
  end

  get "/*" do
    "Default route, this should actually redirect"
  end
  
   
  run!
end




