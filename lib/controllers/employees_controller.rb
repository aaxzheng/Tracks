require_relative "./app_controller/controller_base"
require_relative "./train.rb"


class EmployeesController < ControllerBase
  def index
    @employees = Employee.all
    render :index
  end

  def show
    @employee = Employee.find(params[:id])
  end 
end

router = Router.new
router.draw do
  get Regexp.new("^/employees$"), EmployeesController, :index
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)
