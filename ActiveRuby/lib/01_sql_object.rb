require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    .map {|name| name.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      str_set = column.to_s + "="

      #creates a getter and setter definition for each column argument
      define_method(column) {self.attributes[column]}
      define_method(str_set) {|value| self.attributes[column] = value}
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ? @table_name : self.name.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map {|result| self.new(result)}
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
      SQL
      self.parse_all(result).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_symb = attr_name.to_sym
      raise "unknown attribute '#{attr_symb}'" unless self.class.columns.include?(attr_symb)
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map{|atr| self.send(atr)}
  end

  def insert
    columns = self.class.columns.drop(1)
    col_names = columns.map(&:to_s).join(", ")
    question_marks = (["?"] * columns.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
      SQL

      self.id = DBConnection.last_insert_row_id
  end


  def update
    # ...(
    columns = self.class.columns.drop(1)
    set_line = columns.map {|atr| "#{atr} = ?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1), id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
      SQL
  end

  def save
    id.nil? ? self.insert : self.update
  end
end
