# encoding: UTF-8
# #!/usr/bin/ruby
# # @Author: wujian
# # @Date:   2014-05-05 16:56:10
# # @Last Modified by:   wujian
# # @Last Modified time: 2014-06-15 11:09:15

# require File.dirname(__FILE__)+"/searcher.rb"
# # require 'yaml'
# # include Nlpir
# # nlpir_init(File.dirname(__FILE__),UTF8_CODE)
# # Nlpir.nlpir_init(File.dirname(__FILE__),UTF8_CODE)
# # File.open(File.dirname(__FILE__)+"/ex/10.txt") do |f|
# # 	f.set_encoding 'utf-8','utf-8'
# # 	text = f.read
# # 	# p text
# # 	# text.force_encoding('utf-8')
# # 	# text.scrub!('')
# # 	# m = Nlpir.seg(text)
# # 	# m.each	{ |good|
# # 	# 	p good
# # 	# }
# # 	#puts text
# # 	result = Nlpir.text_proc(text,NLPIR_TRUE)
# # 	m = result.split(' ')
# # 	tt = File.open(File.dirname(__FILE__)+"/ex/45.txt","w")
# # 	#puts result.force_encoding('utf-8')
# # 	#m = result.split(' ')
# # 	m.each	{ |good|
# # 		tt << good.force_encoding('UTF-8') << "\n"
# # 	}
# # 	tt.close
# # end
# # Nlpir.nlpir_exit
# # require File.dirname(__FILE__)+"/filetype_helper.rb"
# # dirpath = File.absolute_path(File.dirname(__FILE__)+"/ex")
# # ft = FiletypeHelper.new
# # files = Dir.glob(dirpath +"/**/*").select{  |f|
# # 			File.file?(f) &&  ft.can_process?(f)
# # 		}
# # files.each{ |file|
# # puts ft.all2text(file)
# # }

# ## p = {"init" => -1, "你妈" => -2}.to_yaml
# # File.open(File.dirname(__FILE__)+"/example/nihao.yaml","w") do |f|
# # 	f << p
# # end
# #nlpir_exit
# # class SelfTest
# #    def self.test
# #       puts "Hello World with self!"
# #    end
# #    class << self
# #   	 alias_method :find, :test
# #    end
# # end
# # SelfTest.find

# m = Searcher.new(0)
# docid = 1
# id =  13
# puts m.find_tf(docid,id).class
# filepath="F:/Xpdf/简历_哈尔滨工业大学_吴健.pdf".encode!('gbk')

# `F:/Xpdf/pdftotext.exe #{filepath}`

# require './nlpir'

#  Nlpir.nlpir_init(File.dirname(__FILE__),UTF8_CODE)
#  puts Nlpir.text_proc("红黑树")
#  Nlpir.nlpir_exit

# require File.expand_path('../filetype_helper.rb', __FILE__)
# dfh =  FiletypeHelper.new
# #puts dfh.all2text(File.dirname(__FILE__)+"/test/test_data/test.txt")
# puts dfh.all2text(File.dirname(__FILE__)+"/test/test_data/test.pdf")
#puts dfh.all2text(File.dirname(__FILE__)+"/test/test_data/test.doc")
#puts dfh.all2text(File.dirname(__FILE__)+"/test/test_data/test.docx")
# puts dfh.all2text(File.dirname(__FILE__)+"/test/test_data/test.xls")
#puts dfh.all2text(File.dirname(__FILE__)+"/test/test_data/test.xlsx")

#puts dfh.all2text(File.dirname(__FILE__)+"/test/test_data/test.pptx")

# require 'thread'

# begin
# 	a = 9
# 	x = Thread.new{
# 		m = a
# 		while true
# 			puts "x: #{m}"
# 		end
# 	}
# 	y = Thread.new{

# 		puts "y:#{a}"
# 		sleep(5)
# 		a = 6
# 		sleep(2)
# 		x.exit
# 		puts "y:#{a}"
# 		sleep(2)
# 		x = Thread.new{
# 		m = a
# 		while true
# 			puts "x: #{m}"
# 		end
# 	}
# 	x.join
# 		# sleep
# 		#x.run
# 	}
# x.join
# y.join
# rescue Exception => e

# end


require File.expand_path("../nlpir", __FILE__)
Nlpir.nlpir_init(File.dirname(__FILE__), UTF8_CODE)
puts Nlpir.text_proc("我爱北京天安门")
Nlpir.nlpir_exit()
# require 'listen'
# require 'rbconfig'
# if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
#   gem 'wdm', '>= 0.1.0'
# end


# begin
# 	st = "F:/合同法"
# 		row=[]
# 		row<< st
# 		if !row.nil? && !row.empty?
# 			paths = ""
# 			row.each{ |item|
# 				paths << "\"#{item}\","
# 			}
# 			puts "正在实时监控：#{paths}"
# 			paths.force_encoding("utf-8")
# 			regex = /\.pdf|\.txt|\.doc|\.docx|\.xls|\.xlsx|\.ppt|\.pptx$/

# 			callback = Proc.new do |modified, added, removed|
# 				if !added.empty?
# 					puts "added absolute path: #{added}"
# 					added.each{  |f|
# 								indexer.add_file(f)
# 					}
# 				end

# 				if !removed.empty?
# 					puts "removed absolute path: #{removed}"
# 					removed.each{  |f|
# 							indexer.add_delete(f)
# 					}
# 				end

# 				if !modified.empty?
# 					puts "modified absolute path: #{modified}"
# 					modified.each{ |f| indexer.add_delete(f);indexer.add_file(f);}
# 				end
# 			end

# 			listener = eval"Listen.to(#{paths} only: /\.pdf|\.txt|\.doc|\.docx|\.xls|\.xlsx|\.ppt|\.pptx$/, &callback)"
# 			#listener = eval"Listen.to(#{ps} only: /\.pdf|\.txt|\.doc|\.docx|\.xls|\.xlsx|\.ppt|\.pptx$/, &callback)"
# 			#listener = Listen.to("F:\\合同法", only: /\.pdf|\.txt|\.doc|\.docx|\.xls|\.xlsx|\.ppt|\.pptx$/, &callback)
# 			listener.start
# 		end
# 		sleep
# 	rescue Exception => e
# 		p e
# 	ensure
# 		if !listener.nil?
# 			listener.stop
# 		end
# 	end