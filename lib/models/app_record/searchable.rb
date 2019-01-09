require_relative 'db_connection'

module Searchable
  def where(params)
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
    p parameters
    parse_all(parameters)
  end
end
