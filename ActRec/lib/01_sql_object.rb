require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

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
    # debugger
    parameters = DBConnection.execute(<<-SQL ,id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
      LIMIT
        1
    SQL
    # debugger
  return nil if parameters.empty?
  self.parse_all(parameters).first
  end

  def initialize(params = {})
    params.each do |k,val|
      # debugger
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
    # columns = self.class.columns.drop(1)
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
    # debugger
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
