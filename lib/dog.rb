# require "pry"

class Dog
	attr_accessor :name, :breed, :id

	def initialize(args)
		args.each {|k,v| self.send("#{k}=",v)}
	end

	def save
		if @id == nil
			DB[:conn].execute("INSERT INTO dogs(name, breed) VALUES(?, ?)", @name, @breed)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		else
			self.update
		end
		self
	end

	def update
		DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", @name, @breed, @id)
	end

	def self.create(args)
		new_dog = Dog.new(args)
		new_dog.save
		new_dog
	end

	def self.new_from_db(row)
		new_dog = Dog.new({})
		new_dog.id = row[0]
		new_dog.name = row[1]
		new_dog.breed = row[2]
		new_dog
	end

	def self.find_by_id(id)
		self.new_from_db( DB[:conn].execute("SELECT * FROM dogs where id = ?", id).flatten )
	end

	def self.find_by_name(name)
		self.new_from_db( DB[:conn].execute("SELECT * FROM dogs where name = ?", name).flatten )
	end

	def self.find_or_create_by(args)
		# row1 = DB[:conn].execute("SELECT * FROM dogs where name = ?", args[:name]).flatten
		# row2 = DB[:conn].execute("SELECT * FROM dogs where breed = ?", args[:breed]).flatten
		# if row1[0] == row2[0]
		row = DB[:conn].execute("SELECT * FROM dogs where name = ? AND breed = ?", args[:name], args[:breed]).flatten
		if row[0] != nil
			self.new_from_db(row)
		else
			self.create(args)
		end
	end

	def self.create_table
		DB[:conn].execute(%Q[
			CREATE TABLE dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT
			)
		])
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE IF EXISTS dogs")
	end

end
