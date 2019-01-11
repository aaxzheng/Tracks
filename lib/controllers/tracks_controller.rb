require_relative "./app_controller/controller_base"
require_relative "./train.rb"


class EmployeesController < ControllerBase
  def index
    @employees = Employee.all
    render :index
  end

  def start
    render :start
  end

  def show
    @employee = Employee.find(params["id"])
    render :show
  end

  def create
      @employee = Employee.new(params["employees"])
      @trains = Train.all
      if @employee.save
        redirect_to "/employees"
      else
        flash.now[:errors] = @employee.errors
        render :new
      end
    end

  def new
    @employee = Employee.new
    @trains = Train.all
    render :new
  end
end

class TrainsController < ControllerBase
  def index
    @trains = Train.all
    render :index
  end

  def show
    @train = Train.find(params["id"])
    render :show
  end

  def create
      @train = Train.new(params["trains"])
      @employee = Employee.all
      if @train.save
        redirect_to "/trains"
      else
        flash.now[:errors] = @train.errors
        render :new
      end
    end

  def new
    @train = Train.new
    @employee = Employee.all
    render :new
  end

end
router = Router.new
router.draw do
  get Regexp.new("^/employees$"), EmployeesController, :index
  get Regexp.new("^/$"), EmployeesController, :start
  post Regexp.new("^/employees$"), EmployeesController, :create
  get Regexp.new("^/employees/new$"), EmployeesController, :new
  get Regexp.new("^/employees/(?<id>\\d+)$"), EmployeesController, :show
  get Regexp.new("^/trains$"), TrainsController, :index
  get Regexp.new("^/trains/(?<id>\\d+)$"), TrainsController, :show
  get Regexp.new("^/trains/new$"), TrainsController, :new
  post Regexp.new("^/trains$"), TrainsController, :create
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use Static
  run app
end.to_app

Rack::Server.start(
 app: app,
 Port: 3000
)
