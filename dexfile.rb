# encoding: UTF-8
#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-05-04 16:53:52
# @Last Modified by:   wujian
# @Last Modified time: 2014-05-17 12:08:37
require 'yaml'
require File.dirname(__FILE__)+"/db.rb"

class Dexfile
	
	def initialize
		@db = DB.new();
	end

	def index2file( index )
		docID = index[:docid]
		# target_file = File.dirname(__FILE__)+ "/dex/index/" +( (docID%20).to_s )+"/"+ docID.to_s
		# 	File.open(target_file,"w") do  |f|
		# 		f << index.to_yaml
		# 	end
		@db.insert_index(docID,index.to_yaml)
	end

	def get_index( docID )
		# filename = File.dirname(__FILE__) + "/dex/index/" + ((docID%20).to_s) +"/"+ docID.to_s
		index={}
		# File.open( filename, "r" ) do |f|
		# 	index = YAML.load( f )
		# end
		index = YAML.load( @db.get_index(docID) )
		return index
	end

	def inverted2file( hash, type="main"  )
		target_file = File.dirname(__FILE__)+ "/dex/inverted/" + type
		File.open(target_file,"w") do  |f|
			f << hash.to_yaml
		end
	end

	def get_inverted(kind="main") #three type :main add delete
		kind.downcase!
		filename = File.dirname(__FILE__)+ "/dex/inverted/" + kind
		index={}
		if File.exist?(filename)
			File.open(filename) do  |f|
				index = YAML.load( f )
			end
		end
		return index
	end

end
