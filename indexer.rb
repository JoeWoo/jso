# encoding: UTF-8
#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-05-06 15:45:07
# @Last Modified by:   wujian
# @Last Modified time: 2014-05-24 21:48:33
require File.dirname(__FILE__)+"/db.rb"
require File.dirname(__FILE__)+"/filetype_helper.rb"
require File.dirname(__FILE__)+"/nlpir.rb"
require File.dirname(__FILE__)+"/dexfile.rb"
require 'yaml'


class Indexer

	def initialize(inverted_index, delete_index, add_index)
		@db = DB.new()
		@parser = FiletypeHelper.new()
		@dexfile = Dexfile.new()
		@inverted_index = inverted_index
		@delete_index = delete_index
		@add_index = add_index
	end

	def init()
		@inverted_index.clear
		@inverted_index["init"] = 123
		@delete_index.clear
		@delete_index["init"] = 123
		@add_index.clear
		@add_index["init"] = 123
		
		@db.init_clear

		save_inverted_index()
	end

	def rebuild()
		@inverted_index.clear
		@inverted_index["init"] = 123
		@delete_index.clear
		@delete_index["init"] = 123
		@add_index.clear
		@add_index["init"] = 123

		@db.rebuild_clear
		dirs = @db.show_Dir().flatten!
		if !dirs.empty?
			dirs.each{  |dirpath|
				if File.directory?(dirpath)
					search_dir_save(dirpath)
				else
					puts dirpath+" is not a directory ! skip !"
					next
				end
			}
		end
		save_inverted_index()
	end

	def main_controller(dir_array)
		set_dirs(dir_array)
		dirs = show_dirs()
		p dirs
		dirs.each{  |dirpath|
			if File.directory?(dirpath)
				search_dir_save(dirpath)
			else
				puts dirpath+" is not a directory ! skip !"
				next
			end
		}
		save_inverted_index()
		puts "first run completed !"

	end

	def set_dirs(dirs_array)
		tmp = modify_dirs(dirs_array)
		tmp.each{  |dirpath|
			if File.directory?(dirpath)
				@db.insert_Dir(dirpath)
			else
				puts dirpath+" is not a directory ! skip !"
				next
			end
		}
	end

	def max_length(x,y)
		tm = x - y
		if tm>0
			return 1
		elsif tm<0
			return -1
		else
			return 0
		end
	end

	def modify_dirs(dir_array)#去重
		tmp = []
		# 将dirpath按长度由短到长排序
		dir_array.sort!{  |x,y|
			max_length(x.length,y.length)
		}
		j = 0
		while(j<dir_array.length)
			k = 0
			while(k<dir_array.length)
				if (dir_array[j] != dir_array[k] && AincludeB?(dir_array[k] , dir_array[j]))
					dir_array.delete_at(k)
					k-=1
				end
				k+=1
			end
			tmp << dir_array[j]
			j+=1
		end
		return tmp
	end

	def AincludeB?(a,b)
		i =  %r{^#{b}} =~ a #b是否是a的前缀
		if i==0  && (a[b.size]=="/" || a[b.size] =="\\")
			return true
		else
			return false
		end
	end

	def add_dir(dirpath)
		#judge dir 是否相互包含 	去重后再决定是否处理
		if File.directory?(dirpath) == false
			return false
		end

		olddirs = show_dirs()
		if olddirs.nil? == false
			olddirs.each{  |old|
				if dirpath != old && AincludeB?(old, dirpath) #old 已包含新的
					return false
				else#old 不包含新的
					next
				end
			}
		end
		# old中均不包含新的 则开始处理
		@db.insert_Dir(dirpath)
		search_dir_save(dirpath)
		save_inverted_index()
	end

	def judge_dir?(dirpath)
		#judge dir 是否相互包含 	去重后再决定是否处理
		if File.directory?(dirpath) == false
			return false
		end
		olddirs = show_dirs()
		if olddirs.nil? == false
			olddirs.each{  |old|
				if dirpath != old && AincludeB?(old, dirpath) #old 已包含新的
					return false
				else#old 不包含新的
					next
				end
			}
		end
		return true
	end

	def show_dirs
		@db.show_Dir().flatten!
	end

	def search_dir_save(dirpath)
		files = Dir.glob(dirpath +"/**/*").select{  |f|
			File.file?(f) &&  @parser.can_process?(f)
		}
		size=0
		files.each{  |filepath|
			begin
				@db.insert_Doc(filepath)
				puts "insert_Doc #{filepath}"
				indexing(filepath)
				size+=1
			rescue
				puts filepath+" here already exist!"
			end
		}
		return size
	end

	def add_file(filepath)
		begin
			@db.insert_Doc(filepath)
			indexing(filepath)
			save_inverted_index()
		rescue Exception => e
			p e
		end
	end

	def indexing(filepath)
		begin
			filepath.encode!('UTF-8')
			puts "正在索引#{filepath}........"
			text = @parser.all2text(filepath)
			if !text.empty?
				# 临时变量
				abstract_end = text.length >= 140 ? 140 : text.length  
				abstract = text[0..abstract_end].encode('utf-8', :invalid => :replace, :undef => :replace,replace: "?")
				abstract.strip!
				abstract.chomp!
				abstract = abstract.delete("\r").delete("\n").delete("\t")
				#abstract = text.encoding.to_s
				docid = @db.find_Doc(filepath)
				most_term = -1
				most_term_times = 0

				#save_txt("F:/tmp/"+docid.to_s+".txt",text)
				index = {:docid => -1 , :docpath => "", :most_term=> 0, :most_term_times => 0,:text => abstract, :my_index => {}, }


				#开始处理

				#分词
				m = Nlpir.seg(text)
				#标引、倒排
				m.each{  |word|
					##查词id
					id = -1
					if  Nlpir.core_words_exist?(word) == false
						id = (Nlpir.get_core_words_size() +1)
						Nlpir.set_core_words(word, id)
					else
						id =  Nlpir.get_core_words_id(word)
					end

					##信息标引 标引频数
					tmp2 = index[:my_index][id]
					if tmp2.nil?
						index[:my_index][id] = 1
					else
						index[:my_index][id]+=1
					end

					tmp3 = index[:my_index][id]
					if tmp3 > most_term_times
						most_term_times = tmp3
						most_term = id
					end
				}
				# 填写index中的除my_index外的字段
			    index[:docid] = docid
				index[:docpath] =  filepath
				index[:most_term] = most_term
				index[:most_term_times] = most_term_times
				## 计算频率 （归一化）
				index[:my_index].each {   |key, weight|
					index[:my_index][key] = 0.5 + 0.5 * (weight / Float(most_term_times))
					##倒排
					tmp = @inverted_index[key]
					if tmp.nil? ###倒排表中无该词
						@inverted_index[key] = [0,Array.new()]
					end
					@inverted_index[key][0] += 1###个数加1
					@inverted_index[key][1] << docid ###文档编号进数组
				}
				# 持久化正向索引
				@dexfile.index2file(index)
			else
				puts filepath +" has no text! skip!"
			end
			# # rescue Exception => e
			# # 	puts e
			# 	puts  filepath+" index error!"
		end
	end

	def add_delete(filepath)
		docid = @db.get_DocID(filepath)
		if(!docid.nil?)
			@db.delete_Doc(docid)
			@delete_index[docid]=1
			@dexfile.inverted2file(@delete_index,"delete")
		end
	end

	def save_inverted_index()
		@dexfile.inverted2file(@inverted_index)
		@dexfile.inverted2file(@delete_index,"delete")
		@dexfile.inverted2file(@add_index,"add")
	end

	def save_txt(docpath,txt)
		File.open(docpath, "w") { |f| f<<txt  }
	end
end
