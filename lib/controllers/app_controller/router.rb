class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method,@controller_class,@action_name =
    pattern,http_method,controller_class,action_name
  end

  def matches?(req)
    if @pattern =~ req.path && @http_method == req.request_method.downcase.to_sym
      return true
    else
      return false
    end
  end

  def run(req, res)
    regex = Regexp.new(@pattern)
    match_data = req.path.match(regex)
    route_params = match_data.named_captures
    controller = @controller_class.new(req,res,route_params)
    controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    route = Route.new(pattern,method,controller_class,action_name)
    @routes.push(route)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.each do |route|
      if route.matches?(req)
        return route
      end
    end
    nil
  end

  def run(req, res)
    route = self.match(req)
    if route
      route.run(req,res)
    else
      res.status = 404
    end
  end
end
