class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.to_s.each_char do |name|
    define_method(name) do
      instance_variable_get("@#{name}")
     end
   end
   names.to_s.each_char do |name|
     define_method("#{name}=") do |value|
       instance_variable_set("@#{name}","#{value}")
     end
   end
  end
end
