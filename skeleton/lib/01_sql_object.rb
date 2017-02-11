require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @all_data ||= nil
    if @all_data.nil?
      @all_data = DBConnection.execute2(<<-SQL)
      SELECT *  FROM cats
      SQL
    end
    list_var = @all_data.first
    list_var.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |col|
      define_method(col) { self.attributes[col] }
      define_method("#{col}=") { |el| self.attributes[col] = el }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name.tableize
  end

  def self.table_name
    p self
    @table_name ||= self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT #{table_name}.* FROM #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map { |hash| self.new(hash) }
  end

  def self.find(id)
    return nil if id.nil?
    data = all
    data.each do |item|
      return item if item.attributes[:id] == id
    end
    nil
  end

  def initialize(params = {})
    available_methods = self.class.columns
    params.each do |k,v|
      k = k.to_sym
      raise "unknown attribute \'#{k}\'" unless available_methods.include?(k)
      self.send("#{k}=", v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.attributes.map { |attr| attr[1]}
  end

  def insert
    col_names = self.class.columns - [:id]
    question_marks = ["?"] * col_names.length
    col_names = col_names.map { |el| el.to_s }.join(",")
    data = DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name}(#{col_names})
      VALUES (#{question_marks.join(",")})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    p "hello"
    # p attributes
    # p self
    # p "hello"
    # p columns
    # p table_name
    # col_names = self.class.columns - [:id]
    # p col_names
    # DBConnection.execute(<<-SQL)
    # SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
