# Tracks
## What is Tracks?
Tracks is a lightweight MvC framework that utilizes self-made ORM and controller components. The ORM is inspired by the framework ActiveRecord and the Controller component is inspired by Ruby on Rails. 
## How do you use Tracks?
1. Bundle Install the gemfile
2. Move over to the controllers folder within lib 
3. Run ```` bundle exec ruby tracks_controller.rb ```` 
4. Open a web browser and navigate to localhost:3000
## ORM Component
The object relational mapping component simplifies and parses information from databases through SQL queries and forms methods and classes to utilize the information. A key feature of this ORM are associations much like those found in ActiveRecord.
### Examples
Belongs to -- an association by which foreign key holders may be connected with the appropriate model/class through that model's foreign key.
```` ruby 
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      foreign = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign).first
    end
  end

````
Belongs to (usage) -- shorthand syntax is available.
```` ruby
class Employee < SQLObject
  attr_accessor :id,:name,:train_id
  belongs_to :train
end
````

Has many -- an association by which foreign key holders are connected to their respective models through the existence of their primary key.
````ruby
  def has_many(name, options = {})
    options = HasManyOptions.new(name,self.name, options)
    define_method(name) do
      primary = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => primary)
    end
  end
````
Has many (usage) -- normal syntax is available as well.
````ruby
class Train < SQLObject
  attr_accessor :id,:name,:maker,:year

  has_many :employees,
  primary_key: :id,
  foreign_key: :train_id,
  class_name: 'Employee'
end
````
## Controller Component
The controller side of the MvC framework handles requests and responses from the server through the use of the middleware, Rack. This allows information from the model to be displayed in several views created by the user. Controller classes are given functionality by inheriting from the parent class, Controller Base, which covers basic methods like those found in Ruby on Rails' ApplicationController.

Sample Controller
````ruby 
class EmployeesController < ControllerBase
  def index
    @employees = Employee.all
    render :index
  end
end
````
This controller can utilize a view with the file name "index.html.erb" found in the views folder and render information passed from the models through Rack.

Rack Middleware
````ruby
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
````
Simple View (index)
````html
<div class="index">
<h1>Trains</h1>

<ul>
  <% @trains.each do |train| %>
  <li>
    <a href= "<%="/trains/#{train.id}"%>"> <%= train.name %> </a>
  </li>
  <% end %>
</ul>


<a href="/trains/new"> Add a new Train </a>
<br>
<a href="/employees">Move to Employee Index</a>
</div>

````
Final Result from localhost:3000

![image](https://user-images.githubusercontent.com/40276721/51061687-1ca62500-15c2-11e9-9b0b-ad558bef4e79.png)

