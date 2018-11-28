require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    tableized = self.class_name.tableize
    manual = self.class_name.downcase + "s"
    return manual == tableized ? tableized : manual
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name,options = {})
    default_hash = {
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id
    }

    default_hash.keys.each do |key|
      self.send("#{key}=", options[key] || default_hash[key])
  end
end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name,options = {})
    default_hash = {
      foreign_key: "#{self_class_name.underscore}_id".downcase.to_sym,
      class_name: name.to_s.singularize.camelcase,
      primary_key: :id
    }

    default_hash.keys.each do |key|
      self.send("#{key}=", options[key] || default_hash[key])
  end
end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      options = self.class.assoc_options[name]
      foreign = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name,self.name, options)
    define_method(name) do
      primary = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => primary)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
