# API-prototype
# Tyler Barth divergio@gmail.com
# idea from Kenzou Yeh.
#
# 

require 'rubygems'
require 'bundler/setup'

require 'sinatra/base'
require 'optparse'
require 'ostruct'
require 'yaml'
require 'json'

#these could be optional
require 'moretext'
require 'faker'
require 'random_data'

class Generator
  def initialize
    @chinese_text =  MoreText.sentenses(30).join('')
    @chinese_text = @chinese_text +  MoreText.sentenses(30).join('')
    @chinese_text = @chinese_text +  MoreText.sentenses(30).join('')
    @chinese_text = @chinese_text +  MoreText.sentenses(30).join('')

    @english_text = Random.paragraphs(20)
  end
  
  def random_string(min,max,language)
    case language
    when "chinese" 
      return random_chinese(min,max)
    when "english" 
      return random_english(min,max)
    else 
      return random_english(min,max)
    end
  end

  def random_english(minlength, maxlength)
    puts minlength.to_s + maxlength.to_s
    @english_text = Random.paragraphs(20)
    start = Random.rand(@english_text.length - maxlength)
    length = Random.rand(maxlength-minlength)+minlength
    puts @english_text[start,length]
    @english_text[start,length]
  end
  
  def random_name
    Faker::Name.name
  end

  def random_username
    name = Faker::Name.name
    name.gsub(/\s+/, "").downcase
  end

  def random_chinese(minlength,maxlength)
    start = Random.rand(@chinese_text.length - maxlength)
    length = Random.rand(maxlength-minlength)+minlength
    return @chinese_text[start,length]
  end

  def random_number(min=0,max=1000)
    Random.rand(max-min)+min
  end
 
  #http://stackoverflow.com/a/88341/1016515
  def random_id
    o =  [('a'..'z'),('0'..'9'),('A'..'Z')].map{|i| i.to_a}.flatten
    string  =  (0...10).map{ o[rand(o.length)] }.join
    return string
  end
 
  def random_letters
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    (0...10).map{ o[rand(o.length)] }.join
  end


  def random_image(horizontal=600,vertical=600, category=nil)
    #random letters are to defeat cacheing
    if category.nil?
      "http://instasrc.com/#{horizontal}x#{vertical}/new/#{random_letters}"
    else
      "http://instasrc.com/#{horizontal}x#{vertical}/#{category}/new/#{random_letters}"
    end
  end

  #the default random_image method, the links are pretty slow. You can override. 
  def random_image_old(horizontal=600,vertical=600)
    image_categories = ['abstract','city','people','transport','animals','food','nature','business', 'nightlife', 'sports','cats','fashion','technics']
    image_category = image_categories[Random.rand(image_categories.length)]
    #append a random id to trick the cache
    return "http://lorempixel.com/" + horizontal.to_s + "/" + vertical.to_s + "/" + image_category + "/" + random_id()[0,5]
  end

end

def parse_options(argv)
  opts = OpenStruct.new
  OptionParser.new do |opts_config|

    #defaults
    opts.generator = "./Generator.rb"

    opts_config.banner = "Usage: cloudfaker.rb [options] rules.yaml"

    opts_config.on("-g", "--generators [Generator.rb]",
                   "File to import containing the Generators subclass. Default is ./Generators.rb") do |gen|
      opts.generator = gen;
    end

    opts_config.on_tail("-h", "--help", "Show this message") do
      puts opts_config
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

  return opts, ARGV
end

#it would be nice to read through and just do sanity checks on the structure
#unfortunately YAML doesn't have a validation language, so this needs to be manually written
def validate_rules(rule_yaml)
  return true
end

#given results of parsing, configure
def configure_from_options(opts,argv)
  generator_class = nil

  unless File.exist?(opts.generator)
    $stderr.puts "WARNING: Generator file #{opts.generator} doesn't exist."
  else
    #http://stackoverflow.com/a/5306426/1016515
    #a bit hacky, wish there was a better way
    existing_classes = ObjectSpace.each_object(Class).to_a
    load opts.generator
    new_classes = ObjectSpace.each_object(Class).to_a - existing_classes
    non_anonymous_new_classes = new_classes.find_all(&:name)
    
    #get the generator class (if any) in this file
    generator_class = non_anonymous_new_classes.each do |someclass| 
      if someclass <= Generator
        break someclass
      end
    end
    
    if generator_class.nil?
      $stderr.puts "WARNING: No Generator subclass found in #{opts.generator}"
    end
  end
  
  #Create a generator (use default if no other)
  if generator_class.nil?
    puts "Using standard generator"
    generator = Generator.new
  else
    puts "Using #{generator_class} generator"
    generator = generator_class.new
  end

  #Load the rules files
  #http://stackoverflow.com/a/3877355/1016515
  if File.exist?(argv.first)
    rule_file_stuff = YAML.load_file(argv.first) 
    
    validate_rules(rule_file_stuff)
    configuration = denil(rule_file_stuff["Configuration"])
    constants = denil(rule_file_stuff["Constants"])
    response_objects = denil(rule_file_stuff["Objects"])
    requests = denil(rule_file_stuff["Requests"])
  else
    $stderr.puts "Can't find rules files."
    exit
  end
  return [configuration, constants, response_objects, requests, generator]
end

#if it's nil, just make it an empty hash instead
def denil(object)
  if object.nil?
    return {}
  else
    return object
  end
end


module Sinatra
  
  #the helper module that creates a new response at runtime based on the 
  # :response_objects, :requests, and :generator
  module CloudFakerHelper
    
    def handle_get(name, info)
      if info["implemented"]
        #Http://stackoverflow.com/questions/11920513/sinatra-app-that-redirects-post-get-requests-with-parameters
        redirect settings.production_server + request.fullpath
      end
      
      #check_conditions, if fail reture fail message
      unless conditions_met?(info)
        halt 400, info["failure"]
      end

      #build success output
      return build_response(info)
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

    def conditions_met?(info)

      unless info["conditions"].nil?
        info["conditions"].each do |key, value|
          #find the parameter for the key
          
          #check params
          parameter = get_parameter(key)
          
          #figure out what it's supposed to be
          if value == "Exists"
            if parameter 
              next
            end
            # Is it a variable?
          elsif /\$(\w*)/ =~ value
            #find the value of the variable in constants
            constants = settings.constants
            if parameter  == constants[$1] 
              next
            end
          elsif parameter == value
            next
          end
          #compare to what it is
          return false
        end
      end
      return true
    end

    #check params, check route params, check HTTP request body
    def get_parameter(key)
      params[key] or params[key.to_sym]
    end
    
    def build_response(info)
      success_response = info["success"].dup
      #for each response_object in the success response
      #substitute the generated object
      success_response.scan(/\$(\w*)/).each do |match|
        match = match.last
        response_object = settings.response_objects[match]
        if response_object.nil?
          $stderr.puts "Warning: Missing object definition for #{match}"
          next
        end

        #check for available additional parameters for the generator
        generator_params = nil
        unless info["generator_params"].nil?
          unless info["generator_params"][match].nil?
            generator_params = info["generator_params"][match]
          end
        end
        
        objects = generate_objects(response_object,generator_params)

        success_response.gsub!(/(\$#{match})/,objects.to_json)
      end
   
      return success_response
    end

    #generates single, fixed number, or between min and max number of objects
    def generate_objects(response_object, extra_params)

      if extra_params.nil? or extra_params["count"].nil?
        return generate_object(response_object,extra_params)
      else
        return count_range(extra_params["count"]).map do |index|
          generate_object(response_object, extra_params)
        end
      end
    end

    #generates single object
    def generate_object(object, extra_params)
      generator = settings.generator

      new_object = {}
      
      object["properties"].each do | property, default_params |
        value = nil;

        extra_params_for_property = \
        if !extra_params.nil? and extra_params.has_key?(property) 
          extra_params[property]
        else
          nil
        end

        #Try to fuse in the extra params (overwriting the old params)
        #extra params take precedence over default params
        parameters = default_params
        unless extra_params.nil?
          parameters = fuse_params(extra_params_for_property, default_params)
        end
        
        #Cases for each type of parameter

        #category type, pick a random value from the categories
        if parameters["values"]
          value = parameters["values"][Random.rand(parameters["values"].length)]
          #fixed value type, just return the fixed value
        elsif parameters["value"]
          value = parameters["value"]
          #contained response_object type, generate that object
        elsif type_is_response_object?(parameters)
          #pass it on to the generator again
          value = generate_objects(settings.response_objects[parameters["type"]], \
                                   extra_params_for_property)
          #parameter type (parameter of a response_object), generate it
        else
          if parameters["generator"].nil?
            $stderr.puts "WARNING: Generator not specified for object property #{property}"
            value = "NOT_SPECIFIED"
          elsif !settings.generator.respond_to?(parameters["generator"]["method"])
            $stderr.puts "WARNING: Generator not found #{parameters["generator"]["method"]}"
            value = "NOT_FOUND"
          else
            value = generate_value(parameters["generator"])
          end
        end
        
        new_object[property] = value
      end

      return new_object
    end
    
    # check if type is a response_object,
    # i.e. instead of parameters of an object like
    # "id" or "imageURL", it's "AuthorObject" or "PhotoObject"
    def type_is_response_object?(parameters)
      if parameters.has_key?("type") and
          settings.response_objects.has_key?(parameters["type"])
        return true
      else
        return false
      end
    end

    #merge the params recurisvely, extra_params take precedence and override default_params
    def fuse_params(extra_params, default_params)
      if default_params.nil? and extra_params.nil?
        $stderr.puts "No specification"
        return nil
      elsif default_params.nil?
        return extra_params
      elsif extra_params.nil?
        return default_params
      elsif !default_params.is_a? Hash
        #extra params override always (if not a hash)
        return extra_params
      else
        #hash case, merge the hashes recursively
        return default_params.merge(extra_params) do |key, oldval, newval| 
          fuse_params(newval,oldval)
        end
      end
    end

    #generates a value for a single property
    #dispatches to generator methods with attached args
    def generate_value(generator_info)
      if generator_info["args"]
        return settings.generator.send(generator_info["method"],*generator_info["args"])
      else
        return settings.generator.send(generator_info["method"])
      end
    end
   
    #interpret the count property, is it a value or a range?
    def count_range(count_param)
      if count_param.is_a? Integer
        return 1..count_param
      else
        max = Random.rand(count_param["max"]-count_param["min"]) + count_param["min"]
        return 1..max
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
  
  before do
    content_type 'application/json'
  end

  configure do
    opts, arg = 0, 0
    if __FILE__ == $0
      opts, argv = parse_options(ARGV)
    else #in test mode, TODO this should be an explicit environment variable
      opts = OpenStruct.new
      opts.generator = "./Test/TestGenerator.rb"
      argv = ["./Test/TestConfig.yaml"]
      self.get '/hello/' do 
        "Hello world" 
      end
    end
    
    @configuration,@constants,@response_objects,@requests,@generator = \
    configure_from_options(opts,argv)
        
    #Actually setup the rules
    establish_routes(@requests)
    #configure the ports/server addresses
    read_configuration(@configuration)

    set :generator, @generator
    set :response_objects, @response_objects
    set :constants, @constants

  end
  
  #this one gets matched to anything that doesn't match before it.
  get "/*" do
    halt 400, "Route not found."
  end
   
  if __FILE__== $0 
    run!
  end
end
