# API-prototype
# Tyler Barth divergio@gmail.com
# idea from Kenzou Yeh.
#

require 'sinatra/base'
require 'optparse'
require 'ostruct'
require 'yaml'

class CloudFaker < Sinatra::Base
  def initialize
    options, argv = self.parse_options(ARGV)
    
    #pass the port to Sinatra
    CloudFaker.set :port, options.port
    
    #import the generator
    
    #http://stackoverflow.com/a/5306426/1016515
    
    if File.exist?(options.generator)
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
    else
      $stderr.puts "WARNING: Generator file #{options.generator} doesn't exist."
    end
    
    if !generator_class
      $stderr.puts "WARNING: No Generator subclass found in #{options.generator}"
      @generator = Generator.new
    else
      @generator = generator_class.new
    end
    
    #Load the rules files
    #http://stackoverflow.com/a/3877355/1016515
    if File.exist?(argv.first)
      rule_file_stuff = YAML.load_file(argv.first)      
      puts rule_file_stuff.inspect
      
      @configuration = rule_file_stuff["Configuration"]
      @response_objects = rule_file_stuff["Objects"]
      @requests = rule_file_stuff["Requests"]
    else
      $stderr.puts "Can't find rules files."
      exit
    end
    
    establish_routes(@requests)

    run!
  end
  
  def establish_routes(requests)
    
  end

  def handle_request
    
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
  
end

class Generator
  def initialize
  end

  def description
    "asdf"
  end

  #the default random_pictures method, the links are pretty slow. You can override. 
  def random_pictures
  
end

if __FILE__ == $0
  CloudFaker.new 
end
