class Person < ActiveRecord::Base
  establish_connection :adapter => 'sqlite3', :database => ':memory:'
  connection.create_table table_name, :force => true do |t|
    t.string :name
  end
end