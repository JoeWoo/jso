#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-05-24 21:41:17
# @Last Modified by:   wujian
# @Last Modified time: 2014-05-24 21:46:39

require File.expand_path("../indexer", __FILE__)
require File.expand_path("../searcher", __FILE__)
require File.expand_path("../dexfile", __FILE__)
require File.expand_path("../query_helper", __FILE__)
require File.expand_path("../nlpir", __FILE__)


begin
	Nlpir.nlpir_init(File.dirname(__FILE__), UTF8_CODE)
		# ask the path of target files to be indexed
		db = DB.new()
		print "please type in  the target file folder path (like'./txt/'):"
		$stdout.flush
		txt_dir = gets
		txt_dir.chop! #delete the gets string tail`s '\n\t'
		txt_dir = File.absolute_path(File.dirname(__FILE__)+"/example") if txt_dir.strip.empty?#default path

		# index: scan all the TXT files and index it
		dexfile = Dexfile.new
		inverted_index = dexfile.get_inverted("main")
		delete_index = dexfile.get_inverted("delete")
		add_index = dexfile.get_inverted("add")

		indexer = Indexer.new(inverted_index, delete_index, add_index)
		array_dir = Array.new()
		array_dir << txt_dir
		array_dir.each{  |dirpath|
			indexer.add_dir(dirpath)
		}

		print "\nIndex completed! \n"
		userinput=[" "]
		searcher = Searcher.new(inverted_index)
		until userinput.empty?
			print "\n", "Search:"
			$stdout.flush
			#get and analyse query line to keywords
			str = gets()
			str.encode!('utf-8')
			querymap = QueryHelper.process(str, inverted_index)

			#search
			result = searcher.search(querymap)

			#sort by rank
			result = result.sort {|a, b| b[1][1] <=> a[1][1]}

			#puts the rankpage
			result.each do |key, docinfo|
				docid = docinfo[0]
				rank = docinfo[1]
				docname = db.get_Doc_name(docid)#add func
				print "file: #{docname}  [rank: #{rank}] ", "\n"
			end

		end#end-until

	ensure
		Nlpir.nlpir_exit()
	end