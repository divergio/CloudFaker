# API-prototype
# Tyler Barth divergio@gmail.com
# idea from Kenzou Yeh.
#


require 'sinatra/base'
require 'optparse'
require 'ostruct'


class Prototyper < Sinatra::Base
  def initialize
    options = self.parse_options(ARGV)
    
    #pass the port to Sinatra
    Prototyper.set :port, options.port
    
    #import the generator
    
    #http://stackoverflow.com/a/5306426/1016515
    if File.exist?(options.generator)
      require options.generator
      puts options.generator.constants
    end

    #load the files

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
      
      opts.banner = "Usage: prototyper.rb [options] rules.yaml"
          
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
    
    options
  end
  
end

class Generator

end

if __FILE__ == $0
  Prototyper.new 
end
