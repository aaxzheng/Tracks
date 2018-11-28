require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # debugger
    wheres = params.map{|key,val| "#{key} = ?"}.join(" AND ")
    valued = params.map{|key,val| val}

    parameters = DBConnection.execute(<<-SQL ,*valued)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{wheres}
    SQL
    # debugger
    p parameters
    parse_all(parameters)
  end
end


class SQLObject
  extend Searchable
  # Mixin Searchable here...
end
