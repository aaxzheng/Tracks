require_relative '../../../db/db_connection'
require 'active_support/inflector'
require_relative 'searchable'
require_relative 'associatable'
require 'byebug'

class SQLObject
extend Searchable
extend Associatable
  def self.columns
    if @columns
      @columns
    else
  columns = DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
    #{table_name}
    SQL
    .first
    @columns = columns.map{|ele| ele.to_sym}
    end
  end

  def self.finalize!

    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end
    end

    self.columns.each do |column|
      define_method("#{column}=") do |arg|
        self.attributes[column.to_sym] = arg
      end
    end

  end

  def self.table_name=(table_name)
    # ...
    @table_name = table_name
  end

  def self.table_name
      @table_name ||= self.to_s.tableize
  end

  def self.all
    all = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    self.parse_all(all)
  end

  def self.parse_all(results)
    results.map {|result| self.new(result) }
  end

  def self.find(id)
    parameters = DBConnection.execute(<<-SQL ,id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
      LIMIT
        1
    SQL
  return nil if parameters.empty?
  self.parse_all(parameters).first
  end

  def initialize(params = {})
    params.each do |k,val|
      if self.class.columns.include?(k.to_sym)
        self.send("#{k.to_sym}=",val)
      else
        raise "unknown attribute '#{k}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
  self.class.columns.map{|column| self.attributes[column]}
  end

  def insert
    col_names = self.class.columns.map(&:to_s).join(", ")
    questions = (["?"]* self.class.columns.length).join(",")
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
    #{self.class.table_name} (#{col_names})
    VALUES
    (#{questions})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    sets = self.class.columns.map {|column| "#{column} = ?"}.join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
    UPDATE
    #{self.class.table_name}
    SET
    #{sets}
    WHERE
      id = #{self.id}
    SQL

  end

  def save
    if self.class.find(self.id).nil?
      self.insert
    else
      self.update
    end
  end
end
