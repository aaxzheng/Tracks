# Tracks
## What is Tracks?
Tracks is a lightweight MvC framework that utilizes self-made ORM and controller components. The ORM is inspired by the framework ActiveRecord and the Controller component is inspired by Ruby on Rails. 
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
