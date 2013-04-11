## CloudFaker: Generate Dummy HTTP server from API Specification

Specify your API in one place, CloudFaker automatically generates a dummy server to use for protyping, as well as Markdown documentation for your server team (and maybe more things in the future).

## Features
- Generate a dummy server that will serve "realistic" responses in your specified format
- A large set of built-in response object generators, plus ability to use your own generators
- Markdown API specification generation
- Mark requests as "implemented" and CloudFaker can redirect the request to the real development server. This allows for incremental movement to the real server as features get implemented.
- Nested response objects (i.e. a random Author can contain a list of Article objects, which are also randomly generated)
- Configure response from the request (i.e. request all the Photos taken by a Photographer with a certain ID, CloudFaker can make it so that the returned Photos have a "PhotographerID" equal to the requested ID)

## Advantages
- More interesting example data helps you troubleshoot designs, impress clients, and keep you motivated because it looks pretty.
- DRY API documentation. Write the API specification once, and use it to generate many things.

## Configuration

To run the server you need
- API specification
- (optionally) custom object generator code

First, make sure you got all the gems:
```gem install bundler
`bundle install```

If you want to run it in Rack or Heroku or something, I don't currently support that. I'll add it soon. In the meantime just run it from commandline:
`ruby cloudfaker.rb API_SPECS.yaml -g Generator.rb file`

For an example application and simple specification, check out the [Demo App for CloudFaker](https://github.com/divergio/DemoAppForCloudFaker "demo app for CloudFaker").
## API Language

The API is specified in a simple YAML format.

Parameters come in from three places:
- HTTP GET URL parameters
- Constants
- HTTP POST/PUT body parameters

CloudFaker just pools them all together, so you can reference any of those using `$` followed by the name of the parameter.

The API specification consists of four sections.

- Configuration: configuration variables like PORT
- Constants: any constants you want to use, could be things like example usernames and passwords, appsecret, etc.
- Objects: The specification for the structure of an object.
- Requests: The expected parameters, conditions for successful response, and structure of response to a request.

### Response Objects

This isn't documented yet.

### Response Specification

This isn't documented yet.

## TODO
- Currently CloudFaker only supports  GET! The other HTTP request types aren't much different, I just haven't added parameter access from POST and PUT request bodies, yet. Once that is done I can support the rest. Sorry.
- Also missing customization from passed in variables
- So, I'm actually missing Markdown generation. I'm working on it. Consider this release the minimum viable product.

## Someday/Maybe
- Monitor the YAML file for changes, reload if it changes (maybe shotgun can do this for us)
- Split all of this into a gem, so you need only require the gem in your generator file  and provide the filename of the rules
- Architectural change to enable better dependency injection on CloudFaker when testing
- More logging with a logging library. You should be able to use the server for basic inspection of request bodies, etc.
- Specification validation. Just walk the hash and check to see everything is as expected.

## Testing Setup

Run `ruby ./Test/cloudfakertest.rb`

I know that this testing architecture is non-optimal. I'm not sure why I can't just say CloudFaker.new(config), but that doesn't work because the "configure" method is always run first. I think I'm using Sinatra in an unexpected way, that's why it's so clunky that I have to hardcode in the location of the test file.

If you are a Sinatra or Rake expert and can suggest an architectural change to allow this kind of load time dependency injection, please do so. But also know that I've searched exhaustively and tried a lot of other methods. It seems like a simple problem to solve, but it may be more complex than you think. Sinatra needs to have compile time access to the changed settings, otherwise the routes can't be added. I'm not sure how to inject the route depencies at compile time to make this work.

## Request for Comment
This is my first real Ruby app, so any Ruby experts out there who want to share their suggestions, I'd like to hear them.
