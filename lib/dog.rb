require 'pry'
require_relative "../config/environment.rb"

class Dog 

attr_accessor :id, :name, :breed


def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
end



def self.create_table 
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
end



def self.drop_table 
    sql = <<-SQL
        DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
end



def save 
    if self.id 
        self.update
    else 
    sql = <<-SQL 
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
    end
end



def self.create(name:, breed:)
    dog = Dog.new(name:name, breed:breed)
    puts(name)
    dog.save
    dog
end


def self.new_from_db(row)
    # id = row[0]
    # name = row[1]
    # breed = row[2]
   

    dog = Dog.new(name: 0, breed: 0)
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
end



def self.find_by_id(num)
    sql = <<-SQL 
    SELECT * FROM dogs 
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, num).map do |row|
        self.new_from_db(row)
    end.first
    # binding.pry
end


def self.find_by_name(name_1)
    sql = <<-SQL 
    SELECT * FROM dogs 
    WHERE name = ?
    SQL

    DB[:conn].execute(sql, name_1).map do |row|
        self.new_from_db(row)
    end.first
    # binding.pry
end

def update
    sql = "UPDATE dogs SET name =?, breed =? WHERE id = ?"

    DB[:conn].execute(sql, self.name, self.breed, self.id)
end

def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
        SELECT * FROM dogs WHERE name =? and breed = ?
    SQL
    row = DB[:conn].execute(sql, name, breed)

    if !row.empty?
       x= self.new_from_db(row.first)
    else 
       x =  self.create(name: name, breed: breed)
    end
    x
end
        ## !STILL WORKING##
        # def self.find_or_create_by(name:, breed:)
        #     sql = <<-SQL
        #         SELECT * FROM dogs WHERE name =? and breed = ?
        #     SQL
        #     row = DB[:conn].execute(sql, name, breed)
        # if !row.empty?
        # x=  row.map do |row_1|
        #     self.new_from_db(row_1)
        #     end.first
        # else 
        #     x =  self.create(name: name, breed: breed)
        #  end
        # x
        # end
         ### !WORKING###




end