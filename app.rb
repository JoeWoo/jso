# encoding: UTF-8
#
# Main
#
require 'rubygems'
require 'json'
require 'thread'
require 'em-websocket'
require 'listen'
require 'rbconfig'
if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
  gem 'wdm', '>= 0.1.0'
end
require File.expand_path("../indexer", __FILE__)
require File.expand_path("../searcher", __FILE__)
require File.expand_path("../dexfile", __FILE__)
require File.expand_path("../query_helper", __FILE__)
require File.expand_path("../nlpir", __FILE__)


#监控线程
def monitor(db,indexer)
	begin
		row = db.show_Dir().flatten!
		if !row.nil? && !row.empty?
			paths = ""
			row.each{ |item|
				paths << "\"#{item}\","
			}
			puts "正在实时监控：#{paths}"
			paths.force_encoding("utf-8")
			regex = /\.pdf|\.txt|\.doc|\.docx|\.xls|\.xlsx|\.ppt|\.pptx$/

			callback = Proc.new do |modified, added, removed|
				if !added.empty?
					puts "added absolute path: #{added}"
					added.each{  |f|
								indexer.add_file(f)
					}
				end

				if !removed.empty?
					puts "removed absolute path: #{removed}"
					removed.each{  |f|
							indexer.add_delete(f)
					}
				end

				if !modified.empty?
					puts "modified absolute path: #{modified}"
					modified.each{ |f| indexer.add_delete(f);indexer.add_file(f);}
				end
			end

			listener = eval"Listen.to(#{paths} only: /\.pdf|\.txt|\.doc|\.docx|\.xls|\.xlsx|\.ppt|\.pptx$/, &callback)"
			#listener = eval"Listen.to(#{ps} only: /\.pdf|\.txt|\.doc|\.docx|\.xls|\.xlsx|\.ppt|\.pptx$/, &callback)"
			listener.start
		end
		sleep
	rescue Exception => e
		p e
	ensure
		if !listener.nil?
			listener.stop
		end
	end
end
#主线程
begin
	Nlpir.nlpir_init(File.dirname(__FILE__), UTF8_CODE)
	db = DB.new()
	dexfile = Dexfile.new()
	inverted_index = dexfile.get_inverted("main")
	delete_index = dexfile.get_inverted("delete")
	add_index = dexfile.get_inverted("add")
	indexer = Indexer.new(inverted_index, delete_index, add_index)

	threadpool = []

	x=Thread.new{

		EM.run {
			threadpool<<Thread.new{
				monitor(db,indexer)
			}
		  EM::WebSocket.run(:host => "localhost", :port => 10081, :debug => false) do |ws|
		    puts "server on 10081...."

		    ws.onopen { |handshake|
		      puts "WebSocket opened #{{
		        :path => handshake.path,
		        :query => handshake.query,
		        :origin => handshake.origin,
		      }}"
		    }

		    ws.onmessage { |msg|
		      	data = JSON.parse(msg)
				cmd = data['cmd']

				case cmd
				when "get_olddir"
					list = db.show_Dir().flatten!
					result=""
					i = 1
					if !list.nil?
						list.each{  |item|
							result<<"<tr class=\"active\"><td>#{i}</td><td>#{item}</td></tr>"
						}
					end
					content = { cmd: cmd, stat: "true", result: result}.to_json
					ws.send(content)
				when "add_dir"
					#data['text'].force_encoding('gbk')
					str = data['text'].encode!('utf-8')
					str.force_encoding('utf-8')
					count = data['count'].to_i
					result = ""
					stat = "true"
					if indexer.judge_dir?(str)
						result = "<tr class=\"active\"><td>#{count+1}</td><td>#{str}</td></tr>"
					else
						result = "false"
						stat = "false"
					end
					content = {cmd: cmd, stat: stat, result: result}.to_json
					ws.send(content)
				when "save_settings"
					str = data['text']
					str.slice!(-1)
					dir_array = str.split("#")
					dir_array.each{  |dirpath|
						dirpath.gsub!(/\\/,'/')
						indexer.add_dir(dirpath)
						#puts dirpath
					}
					content = { cmd: cmd, stat: "true", :result => "100%" }.to_json
					ws.send(content)
					threadpool[0].exit
					threadpool[0]=Thread.new{
						monitor(db,indexer)
					}
				when "vote"
					docid = data['text'].to_i
					@query.each_key{  |term_id|
						if !inverted_index[term_id][1][docid].nil?
							inverted_index[term_id][1][docid] += 1
							puts "#{term_id},#{docid}"
						else
							inverted_index[term_id][1][docid] = 1
						end
					}
				when "search"
					str = data['text']
					type = data['type']
					searcher = Searcher.new(inverted_index, delete_index, add_index)
					querymap = QueryHelper.process(str, inverted_index)
					@query = querymap
					#search
					t = Time.now
						result = searcher.search(querymap)
						result_list = ""
						result_list.clear
						id = 0
						ok = "yes"
						if result.empty? == false
							#sort by rank
							result = result.sort {|a, b| b[1] <=> a[1]}
							# 加入点击干扰排名
							# Rank = v/(v+m) Sim + m/(v+m) average(Sim)
							sim_sum = 0
							result.each{  |result_info|
								sim_sum += result_info[1]
							}
							sim_average = sim_sum/result.length
							m = 1
							result.each{  |result_info|
								v = 0
								querymap.each_key{  |term_id|
									vote_i = inverted_index[term_id][1][result_info[0]]
									v += vote_i if !vote_i.nil?
								}
								result_info[1] = Float(v)/(v+m)*result_info[1] + Float(m)/(v+m)*sim_average
							}

							#puts the rankpage
							result = result.sort {|a, b| b[1] <=> a[1]}
							m = 0
							querymap.each_key{  |term_id|
								vote_i = inverted_index[term_id][1][result[-1][0]]
								m += vote_i if !vote_i.nil?
							}
							result.each{  |result_info|
								v = 0
								querymap.each_key{  |term_id|
									vote_i = inverted_index[term_id][1][result_info[0]]
									v += vote_i if !vote_i.nil?
								}
								result_info[1] = Float(v)/(v+m)*result_info[1] + Float(m)/(v+m)*sim_average
							}

							#puts the rankpage
							result = result.sort {|a, b| b[1] <=> a[1]}

							id = 0
							result.each do |docinfo|
								docid = docinfo[0]
								rank = docinfo[1]
								filename = docinfo[2]
								ri = filename.rindex('.')
								filetype = filename[ri+1..-1]
								if(type == "all")

								elsif(type == "doc")
									if(filetype == "pdf" || filetype == "doc" || filetype == "docx" || filetype == "txt")
									else
										next
									end
								elsif(type == "xls")
									if(filetype == "xls" || filetype == "xlsx")
									else
										next
									end
								elsif(type == "ppt")
									if(filetype == "ppt" || filetype == "pptx")
									else
										next
									end
								elsif(type == "other")

								end
								fullpath = docinfo[3]
								abstract = docinfo[4]
								item1="#{id}-0"
								item2="#{id}-1"
								result_list << "<li id=\"#{id}\" class=\"item\"><div id=\"#{item1}\" class=\"filename\"><a class=\"filename_link\" href=\"file://#{fullpath}\" onclick=\"vote(#{docid})\">#{filename}</a><br/></div><div id=\"#{item2}\"><a class=\"filepath\" href=\"file://#{fullpath}\" onclick=\"vote(#{docid})\">#{fullpath}</a><p class=\"abstract\">#{abstract}	</p></div></li> "
								id+=1
							end
						else
							ok = "no"
							result_list << "对不起，根据您的搜索用词，未能检索到相关的文件。"
						end
					if result_list.empty? #无该文件格式的结果
						ok = "no"
						result_list << "对不起，根据您的搜索用词，未能检索到相关的文件。"
					end
					timecost = Time.now - t
					content = { cmd: cmd, stat: "true", ok: ok, result: result_list, count: id, timecost: timecost }.to_json
					ws.send(content)
				when "bigsearch"
					puts "fdsafdsafdsfadsfasfs"
					str = data['text']
					searcher = Searcher.new(inverted_index, delete_index, add_index)
					querymap = QueryHelper.process(str, inverted_index)
					@query = querymap
					#search
					t = Time.now
						result = searcher.search(querymap)
						result_list = ""
						result_list.clear
						id = 0
						ok = "yes"
						if result.empty? == false
							#sort by rank
							result = result.sort {|a, b| b[1] <=> a[1]}

							# 加入点击干扰排名
							# Rank = v/(v+m) Sim + m/(v+m) average(Sim)
							sim_sum = 0
							result.each{  |result_info|
								sim_sum += result_info[1]
							}
							sim_average = sim_sum/result.length
							m = 1
							result.each{  |result_info|
								v = 0
								querymap.each_key{  |term_id|
									vote_i = inverted_index[term_id][1][result_info[0]]
									v += vote_i if !vote_i.nil?
								}
								result_info[1] = Float(v)/(v+m)*result_info[1] + Float(m)/(v+m)*sim_average
							}
							#puts the rankpage
							result = result.sort {|a, b| b[1] <=> a[1]}
							m = 0
							querymap.each_key{  |term_id|
								vote_i = inverted_index[term_id][1][result[-1][0]]
								m += vote_i if !vote_i.nil?
							}
							result.each{  |result_info|
								v = 0
								querymap.each_key{  |term_id|
									vote_i = inverted_index[term_id][1][result_info[0]]
									v += vote_i if !vote_i.nil?
								}
								result_info[1] = Float(v)/(v+m)*result_info[1] + Float(m)/(v+m)*sim_average
							}

							#puts the rankpage
							result = result.sort {|a, b| b[1] <=> a[1]}
							id = 0
							result.each do |docinfo|
								docid = docinfo[0]
								rank = docinfo[1]
								filename = docinfo[2]

								fullpath = docinfo[3]
								abstract = docinfo[4]
								item1="#{id}-0"
								item2="#{id}-1"
								result_list << "<li id=\"#{id}\" class=\"item\"><div id=\"#{item1}\" class=\"filename\"><a class=\"filename_link\" href=\"file://#{fullpath}\" onclick=\"vote(#{docid})\">#{filename}</a><br/></div><div id=\"#{item2}\"><a class=\"filepath\" href=\"file://#{fullpath}\" onclick=\"vote(#{docid})\">#{fullpath}</a><p class=\"abstract\">#{abstract}	</p></div></li> "
								id+=1
							end
						else
							ok = "no"
							result_list << "对不起，根据您的搜索用词，未能检索到相关的文件。"
						end
					if result_list.empty? #无该文件格式的结果
						ok = "no"
						result_list << "对不起，根据您的搜索用词，未能检索到相关的文件。"
					end
					timecost = Time.now - t
					content = { cmd: cmd, stat: "true", ok: ok, result: result_list, count: id, timecost: timecost }.to_json
					ws.send(content)
				when "rebuild"
					indexer.rebuild()
					content = { cmd: cmd, stat: "true", :result => "100%" }.to_json
					ws.send(content)
					threadpool[0].exit
					threadpool[0]=Thread.new{
						monitor(db,indexer)
					}
				when "init"
					indexer.init()
					content = { cmd: cmd, stat: "true", :result => "100%" }.to_json
					ws.send(content)
					threadpool[0].exit
					threadpool[0]=Thread.new{
						monitor(db,indexer)
					}
				end
			}

		    ws.onclose {
		      puts "WebSocket closed"
		    }

		    ws.onerror { |e|
		      puts "Error: #{e.message}"
		    }
		end
		}
	}


	x.join
rescue Exception => e
	p e
	puts "server error!"
ensure
	puts "正在保存信息"
	dexfile.inverted2file(inverted_index,"main")
	dexfile.inverted2file(delete_index,"delete")
	Nlpir.nlpir_exit()
end


