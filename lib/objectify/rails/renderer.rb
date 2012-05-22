module Objectify
  module Rails
    class Renderer
      def initialize(controller)
        @controller = controller
      end

      def template(template, opts)
        @controller.render opts.merge(:template => template)
      end

      def action(action, opts)
        @controller.render opts.merge(:action => action)
      end

      def partial(partial, opts)
        @controller.render opts.merge(:partial => partial)
      end

      def file(file, opts)
        @controller.render opts.merge(:file => file)
      end

      def nothing(opts)
        @controller.render opts.merge(:nothing => true)
      end

      def render(opts)
        @controller.render opts
      end

      def respond_to
        @controller.respond_to do |format|
          yield(format)
        end
      end

      def redirect_to(*args)
        @controller.redirect_to(*args)
      end

      def data(data)
        @controller.instance_variable_set(:@objectify_data, data)
      end
    end
  end
end
