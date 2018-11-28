require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    vals = params.values
    where_line = params.map {|key,_| "#{key.to_s} = ?"}.join(" AND ")
    results = DBConnection.execute(<<-SQL, vals)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
