# encoding: UTF-8
#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-05-03 18:43:09
# @Last Modified by:   wujian
# @Last Modified time: 2014-05-24 12:38:13
#
require "sqlite3"

class DB

	def initialize
		# Open a database
		@db = SQLite3::Database.new(File.dirname(__FILE__)+"/dex/test.db")
	end

	def  find_Doc(docpath)
		row = @db.execute("SELECT DocID FROM Doc Where DocPath=? and Deleteflag = ? ",[docpath,'0'])
		if row.empty?
			return nil
		else
			return row[0][0]
		end
	end

	def get_DocID(docpath)
		row = @db.execute("SELECT DocID FROM Doc Where DocPath=? and Deleteflag = ? ",[docpath,'0'])
		if row.empty?
			return nil
		else
			return row[0][0]
		end
	end

	def insert_Doc(docpath)
		if find_Doc(docpath) == nil
			@db.execute("INSERT INTO Doc(DocPath, DocDate, Deleteflag) VALUES (?, ?, ?)",[docpath, File.new(docpath).mtime.to_s, '0'])
		end
	end

	def delete_Doc(docid)
		@db.execute("UPDATE Doc Set Deleteflag = ? Where Docid=?",['1',docid])
	end

	def get_Doc_sum()
		@db.execute("SELECT COUNT(DocID) From Doc")
	end

	def get_Doc_path(docid)
		row = @db.execute("SELECT DocPath FROM Doc Where DocID=?",docid)
		if row.empty?
			return nil
		else
			return row[0][0]
		end
	end

	def get_Doc_name(docid)
		path = get_Doc_path(docid)
		i =  path.rindex('/')
		return path[i+1..-1]
	end


	def insert_Dir(dirpath)
		begin
			@db.execute("INSERT INTO Dir (DirPath) VALUES (?)",dirpath)
		rescue
			 puts dirpath + " is alreay exist!"
		end

	end

	def delete_Dir(dirpath)
		@db.execute("DELETE FROM Dir Where DirPath=?", dirpath)
	end

	def show_Dir()
		@db.execute("SELECT DirPath From Dir")
	end

	def insert_index(docID,index)
		begin
			@db.execute("INSERT INTO DocIndex (DocID, DocIndex) VALUES(?,?)",docID,index)
		rescue
			@db.execute("UPDATE DocIndex SET DocIndex = ? Where DocID = ?",index,docID)
		end
	end

	def get_index(docID)
		row = []
		begin
			row = @db.execute("SELECT DocIndex From DocIndex Where DocID = ?",docID)
			if row[0][0].nil?
				return nil
			else
				return row[0][0]
			end
		rescue
			puts docID + " has no record!"
		end
		
	end

	def init_clear()
		begin
			@db.execute("delete from doc")
			@db.execute("delete from dir")
			@db.execute("delete from docindex")
		rescue
			puts "clear error!"
		end
	end

	def rebuild_clear()
		begin
			@db.execute("delete from doc")
			@db.execute("delete from docindex")
		rescue
			puts "rebulid clear error!"
		end
	end	

	private
	def create_table_doc
		#Create a table Doc
		@db.execute <<-SQL
		CREATE TABLE Doc(
			DocID     INTEGER PRIMARY KEY NOT NULL,
			DocPath TEXT   NOT NULL ,
			DocDate  TEXT     NOT NULL);
		CREATE INDEX DocPath_index ON Doc (DocPath);
		SQL
	end

	def delete_table_doc
		@db.execute <<-SQL
		DELETE * from Doc
		SQL
	end

	def create_table_dir
		#Create a table Doc
		@db.execute <<-SQL
		CREATE TABLE Dir(
			DirID     INTEGER PRIMARY KEY NOT NULL,
			DirPath TEXT   NOT NULL UNIQUE );
		CREATE INDEX DirPath_index ON Dir (DirPath);
		SQL
	end

	def delete_table_dir
		@db.execute <<-SQL
		DELETE * from Dir
		SQL
	end
end





	# insert_Doc("/home/wujian/github/IR/jso/test/test_data/test.pdf")
	# get_DocID("/home/wujian/github/IR/jso/test/test_data/test.pdf")
	#delete_Doc("/home/wujian/github/IR/jso/test/test_data/test.pdf")
	#puts File.new("/home/wujian/github/IR/jso/test/test_data/test.pdf").mtime.to_s





	# @docpath = "/home/wujian/github/IR/jso/test/test_data/test.pdf"
	# @docdate = File.new("/home/wujian/github/IR/jso/test/test_data/test.pdf").mtime.to_s
	# db.execute("INSERT INTO Doc(DocPath, DocDate) VALUES (?, ?)",[@docpath, @docdate])
	# # Execute a few inserts
	# {
	#   "one" => 1,
	#   "two" => 2,
	# }.each do |pair|
	#   db.execute "insert into numbers values ( ?, ? )", pair
	# end

	# # Execute inserts with parameter markers
	# db.execute("INSERT INTO students (name, email, grade, blog)
	#             VALUES (?, ?, ?, ?)", [@name, @email, @grade, @blog])

	# # Find a few rows
	# db.execute( "select * from numbers" ) do |row|
	#   p row
	# end

	# save_2dir(File.dirname(__FILE__)+"/test",".temp.txt")
