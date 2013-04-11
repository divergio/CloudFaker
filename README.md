## CloudFaker: The DRY RESTful API-specification and dummy server program

Specify your API in one place, CloudFaker automatically generates a dummy server to use for protyping, as well as Markdown documentation for your server team (and maybe more things in the future).

## Features
- Generate a dummy server that will serve "realistic" responses in your specified format
- A large set of built-in response object generators, plus ability to use your own generators
- Markdown API specification generation
- Mark requests as "implemented" and CloudFaker can redirect the request to the production server
-

## Configuration

To run the server you need
- API specification

If you want to run it in Rack or Heroku or something, I don't currently support that. I'll add it soon. In the meantime just run it from commandline:
`ruby cloudfaker.rb API_SPECS.yaml -g Generator.rb file`

I don't curren
It currently doesn't support

## API Language

The API is specified in a simple YAML format.

Parameters come in from three places:
- HTTP GET URL parameters
- Constants
- HTTP POST/PUT body parameters

CloudFaker just pools them all together, so you can reference any of those using `$` followed by the name of the parameter.

The API specification consists of four sections.

- Configuration : you specify the



### Response Objects

### Response Specification

# TODO
- Currently CloudFaker only supports to GET! The other HTTP request types aren't much different, I just haven't added parameter access from POST and PUT request bodies, yet. Once that is done I can support the rest.
- No gem or bundler or RVM. I just ran out of time to set that up and test it.

# Someday/Maybe
- Monitor the YAML file for changes, reload if it changes (maybe shotgun can do this for us)
- Split all of this into a gem, so you need only require the gem in your generator file  and provide the filename of the rules
- It should be modularized so that you do something like CloudFaker.new(config), but something is strange about Sinatra that I can't get it to work this way.
- More logging

# Testing Setup
I know that it is messed up. I'm not sure why I can't just say CloudFaker.new(config), but that doesn't work because the "configure" method is always run first. I think I'm using Sinatra in an unexpected way, that's why it's so clunky that I have to write a file with the test data.

If you are a Sinatra or Rake expert and can suggest an architectural change, please do so. But also know that I've searched exhaustively and tried a lot of other methods. It seems like a simple problem to solve, but it may be more complex than you think. Sinatra needs to have compile time access to the changed settings, otherwise the routes can't be added. I'm not sure how to inject the route depencies at compile time to make this work.

# Request for Comment
This is my first real Ruby app, so any Ruby experts out there who want to share their suggestions, I'd like to hear them.