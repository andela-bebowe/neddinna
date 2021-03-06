module Neddinna
  class Route
    attr_reader :klass_name, :path, :method, :params
    def initialize(route_array)
      @path = route_array[0]
      @params = route_array.last
      @klass_name = route_array[1][:klass]
      @method = route_array[1][:method]
    end

    def klass
      Module.const_get(klass_name + "Controller")
    end

    def execute(env)
      controller = klass.new(env)
      controller.add_params(params) if params
      text = controller.send(method.to_sym)
      if controller.get_response
        controller.get_response.to_a
      elsif controller.template(method)
        controller.render method
      else
        Rack::Response.new([text], 200, "Content-Type" => "text/html")
      end
    end
  end
end
