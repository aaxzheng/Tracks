require_relative "./app_controller/controller_base"
require_relative "../../train.rb"


class EmployeesController < ControllerBase
  def index
    @employees = Employee.all
    render :index
  end

end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  EmployeesController.new(req, res).index
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
