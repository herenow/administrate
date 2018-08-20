module Administrate
  class Namespace
    def initialize(namespace)
      @namespace = namespace
    end

    def resources
      @resources ||= routes.map(&:first).uniq.map do |path|
        Resource.new(namespace, path)
      end
    end

    def index_resources
      @index_resources ||= begin
        index_routes = routes.select do |_path, action|
          action == "index"
        end

        index_routes.uniq!

        index_routes.map do |route|
          path = route[0]

          ::Administrate::Namespace::Resource.new(namespace, path)
        end
      end
    end

    def routes
      @routes ||= all_routes.select do |controller, _action|
        controller.starts_with?("#{namespace}/")
      end.map do |controller, action|
        [controller.gsub(/^#{namespace}\//, ""), action]
      end
    end

    private

    attr_reader :namespace

    def all_routes
      Rails.application.routes.routes.map do |route|
        route.defaults.values_at(:controller, :action).map(&:to_s)
      end
    end
  end
end
