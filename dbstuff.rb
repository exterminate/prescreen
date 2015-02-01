require 'sequel'
# from http://sequel.jeremyevans.net/rdoc/files/README_rdoc.html


DB = Sequel.connect('sqlite://prescreen.db')

DB.create_table :names do
  primary_key :id
  String :name
  Int :manuscripts
  String :date
end


DB.create_table :meetings do
  primary_key :id
  String :date
  String :time
end

items = DB[:papers] # Create a dataset
items = DB[:meetings] # Create a dataset

# Populate the table
=begin
items.insert(:name => 'abc', :price => rand * 100)
items.insert(:name => 'def', :price => rand * 100)
items.insert(:name => 'ghi', :price => rand * 100)
=end
