= objectify

Objectify is a framework that codifies good object oriented design practices for building maintainable rails applications.

= How it works

Objectify has two primary components:

  1. A dependency injection framework. Objectify automatically injects dependencies in to objects in manages based on parameter names. So, if you have a service method signature like: PictureCreationService#call(params), objectify will automatically inject the request's params when it calls that method. It's very simple to create custom injections by implementing Resolver classes. More on that below.

  2. A request execution framework that separates the responsibilities that are typically jammed together in rails controller actions in to 3 types of components: Policies, Services, and Responders. Properly separating and assigning these responsibilities makes for far more testable code, and better reuse of components.

The flow of an objectify request is as follows:

  1. The policy chain is resolved (based on the various levels of configuration) and executed. Objectify calls the #allowed?(...) method on each policy in the chain. If one of the policies fails, the chain short-circuits at that point, and objectify executes the configured responder for that policy.

  An example Policy:

```ruby
class RequiresLoginPolicy
  # more on how current user gets injected below
  def allowed?(current_user) 
    !current_user.nil?
  end
end
```

  A responder, in case that policy fails.

```ruby
class UnauthenticatedResponder
  # yes, at some point we probably need a better interface
  # for handling responses, but this'll do for now.
  def call(controller)
    controller.redirect_to controller.login_url
  end
end
```

  Here's how you setup the RequiresLoginPolicy to run by default (you can configure specific actions to ignore it), and connect the policy with its responder.

```ruby
# config/routes.rb
MyApp::Application.routes.draw do
  objectify.defaults :policies => :requires_login
  objectify.policy_responders :requires_login => :unauthenticated
end
```

== Copyright

Copyright (c) 2012 James Golick, BitLove Inc. See LICENSE.txt for
further details.
