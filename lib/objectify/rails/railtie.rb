module Objectify
  module Rails
    class Railtie < ::Rails::Railtie
      initializer "objectify.reloader" do
        ActionDispatch::Callbacks.to_prepare do
          ::Rails.application.objectify.reload
        end
      end
    end
  end
end
