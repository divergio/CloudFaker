## CloudFaker: The DRY RESTful API-specification and dummy server program

Specify your API in one place, produce the documents to give to the server team and the dummy server automatically.

Too many acronyms.

Ruby newby, so any stylistic suggestions are welcome.

## Configuration

To run the server you need
- API specification

If you want to run it in Rack or Heroku or something, I don't currently support that. I'll add it soon. In the meantime just run it from commandline:
`ruby cloudfaker.rb API_SPECS.yaml -g Generator.rb file`

I don't curren

It currently doesn't support

## API Language

Parameters come in from three places:
- HTTP GET URL parameters
- Constants
- HTTP POST/PUT body parameters

CloudFaker just pools them all together, so you can reference any of those using `$` followed by the name of the parameter.




### Response Objects

### Response Specification

# Someday/Maybe
- Monitor the YAML file for changes, reload if it changes (maybe shotgun can do this for us)
- Split all of this into a gem, so you need only require the gem in your generator file  and provide the filename of the rules
- It should be modularized so that you do something like CloudFaker.new(config), but something is strange about Sinatra that I can't get it to work this way.
- More logging

# Testing Setup
I know that it is messed up. I'm not sure why I can't just say CloudFaker.new(config), but that doesn't work because the "configure" method is always run first. I think I'm using Sinatra in an unexpected way, that's why it's so clunky that I have to write a file with the test data.

If you are a Sinatra or Rake expert and can suggest an architectural change, please do so. But also know that I've searched exhaustively and tried a lot of other methods. It seems like a simple problem to solve, but it may be more complex than you think. Sinatra needs to have compile time access to the changed settings, otherwise the routes can't be added.

## TODO
- rvm (including redoing how the tests get run)
- bundler

This is my first Ruby app, so I didn't learn how to do that yet.
