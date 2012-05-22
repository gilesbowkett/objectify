# objectify

Objectify is a framework that codifies good object oriented design practices for building maintainable rails applications.

## How it works

Objectify has two primary components:

  1. A request execution framework that separates the responsibilities that are typically jammed together in rails controller actions in to 3 types of components: Policies, Services, and Responders. Properly separating and assigning these responsibilities makes for far more testable code, and facilitates better reuse of components.

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
          def call(controller, renderer)
            renderer.redirect_to controller.login_url
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

    2. If all the policies succeed, the service for that action is executed. A service is typically responsible for fetching and / or manipulating data.

      A very simple example of a service:

      ```ruby
        class PicturesCreateService
          # the current_user and the request's params will be automatically injected here.
          def call(current_user, params)
            current_user.pictures.create params[:picture]
          end
        end
      ```

    3. Finally, the responder is executed. Following with our Pictures#create example:

      ```ruby
        class PicturesCreateResponder
          # service_result is exactly what it sounds like
          def call(service_result, controller, renderer)
            if service_result.persisted?
              renderer.redirect_to service_result
            else
              # this is the only way that you can pass data to the view layer
              # and you can only pass one thing. Hint: use a presenter.
              renderer.data(service_result)
              renderer.render :template => "pictures/edit.html.erb"
            end
          end
        end
      ```

  2. A dependency injection framework. Objectify automatically injects dependencies in to objects it manages based on parameter names. So, if you have a service method signature like: PictureCreationService#call(params), objectify will automatically inject the request's params when it calls that method. It's very simple to create custom injections by implementing Resolver classes. More on that below.


## Custom Injections

Several of the above methods have parameters named 'current_user'. By default, objectify won't know how to inject a parameter by that name, so it'll raise an error when it encounters one. Here's how to create a custom resolver for it that'll automatically get found by name.

```ruby
# app/resolvers/current_user_resolver.rb
class CurrentUserResolver
  def initialize(user_finder = User)
    @user_finder = user_finder
  end

  # note that resolvers themselves get injected
  def call(session)
    @user_finder.find_by_id(session[:current_user_id])
  end
end
```

### Why did you constructor-inject the User constant in to the CurrentUserResolver?
  
Because that makes it possible to test in isolation.

```ruby
describe "CurrentUserResolver" do
  before do
    @user        = stub("User")
    @user_finder = stub("UserFinder", :find_by_id => nil)
    @user_finder.stubs(:find_by_id).with(10).returns(@user)

    @resolver = CurrentUserResolver.new(@user_finder)
  end

  it "returns whatever the finder returns" do
    @resolver.call({:current_user_id => 42}).should be_nil
    @resolver.call({:current_user_id => 10}).should == @user
  end
end
```

## What if I have a bunch of existing rails code?

Objectify has a legacy mode that allows you to execute the policy chain as a before_filter in your ApplicationController. You can also configure policies (and skip_policies) for your "legacy" actions. That way, access control code is shared between the legacy and objectified components of your application.

I completely rewrote our legacy authentication system as a set of objectify policies, resolvers, and services - you can see an example of that at https://github.com/bitlove/objectify_auth.

Here's how to run the policy chain in your ApplicationController - it'll figure out which policies to run itself:

```ruby
class ApplicationController < ActionController::Base
  include Objectify::Rails::ControllerHelpers

  around_filter :objectify_around_filter
  before_filter :execute_policy_chain
end
```

And to configure policies for a legacy action:

```ruby
# config/routes.rb
MyApp::Application.routes.draw do
  objectify.defaults :policies => :requires_login
  objectify.policy_responders :requires_login => :unauthenticated
  objectify.legacy_action :controller, :action, :policies => [:x, :y, :z],
                                                :skip_policies => [:requires_login]
end
```

Then, you need to create an ObjectifyController that inherits from ApplicationController, and configure objectify to use that:

```ruby
# app/controllers/objectify\_controller.rb
class ObjectifyController < ApplicationController
  include Objectify::Rails::LegacyControllerBehaviour
end
```

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...snip...
    objectify.objectify_controller = "objectify"
  end
end
```

## Views

Objectify has two major impacts on your views.

  1. You can only pass one variable from an objectified action to the controller. You do that by calling renderer.data(the_object_you_want_to_pass). Then, you call objectify_data in the view to fetch the data. If it's not there, it'll raise an error. Use a presenter or some kind of other struct object to pass multiple objects to your views.

  2. You can reuse your policies in your views. require "objectify/rails/helpers" and add Objectify::Rails::Helpers to your helpers list, and you'll get a helper called #policy_allowed?(policy_name). Yay code reuse.

## Installation

```ruby
# Gemfile
gem "objectify", "> 0"

# config/application.rb
module MyApp
  class Application < Rails::Application
    require "objectify/rails/application"
    require "objectify/rails/controller"
    # only have to require this if you want objectify logging
    require "objectify/rails/log_subscriber" 
    include Objectify::Rails::Application
  end
end
```

## Credits

  * Author: James Golick @jamesgolick
  * Advice (and the idea for injections based on method parameter names): Gary Bernhardt @garybernhardt
  * Feedback: Jake Douglas @jakedouglas
  * Feedback: Julie Haché @juliehache
  * The gem name: Andrew Kiellor @akiellor

## The other objectify gem

  If you were looking for the gem that *used* to be called objectify on rubygems.org, it's here: https://github.com/akiellor/objectify

## Copyright

Copyright (c) 2012 James Golick, BitLove Inc. See LICENSE.txt for
further details.
