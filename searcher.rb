# encoding: UTF-8
require File.dirname(__FILE__)+"/db.rb"
require File.dirname(__FILE__)+"/dexfile.rb"

class Searcher

	def initialize(inverted_index, delete_index, add_index, index_cache=nil)
		@db = DB.new()
		@dexfile = Dexfile.new()
		@inverted_index = inverted_index
		@delete_index = delete_index
		@add_index = add_index
		@index_cache = index_cache
	end

	def search(query_map)
		p query_map
		num_docs = @db.get_Doc_sum[0][0]
		query_result = Array.new
		
		rdocs_map = Hash.new #相关文档hashmap

		# 生成查询向量权值空间
		mold_query = 0.0 # 查询向量的模
		query_map.each do |id, tf|
			next unless @inverted_index.has_key?(id)
			invertedItem = @inverted_index[id]
			#ni = ni is  sum of documents that include word == id
			ni = invertedItem[0]
			idf = 1.0 + Math.log(num_docs / Float(ni))
			query_term_weight = tf * idf
			query_map[id] = query_term_weight
			mold_query += query_term_weight**2

			# 相关文档index调入内存
			docs_found = invertedItem[1]
			docs_found.each{ |docid|
				if (!@delete_index.has_key?(docid)) && (!rdocs_map.has_key?(docid)) 
					rdocs_map[docid] =  @dexfile.get_index(docid)
				end
			}
		end

		# 生成相关文档权值空间
		mold_docs_list = Array.new
		rdocs_map.each do |docid, index|
			mold_doc = 0.0
			index[:my_index].each do |id, tf|
				ni = @inverted_index[id][0]
				idf = 1.0 + Math.log(num_docs / Float(ni))
				weight = tf * idf
				index[:my_index][id] = weight
				mold_doc += weight**2
			end
			mold_docs_list << mold_doc

			# 计算docid与query的余弦相似度
			mold_multi = Math.sqrt(mold_doc) * Math.sqrt(mold_query)
			dot_product = 0.0
			query_map.each do |id, weight|
				if index[:my_index].has_key?(id)
					dot_product += weight*index[:my_index][id]
				end
			end

			sim = dot_product / mold_multi
			docpath = index[:docpath]
			i =  docpath.rindex('/')
		    docname = docpath[i+1..-1]
		    abstract = index[:text]
		    query_result << [docid, sim, docname, docpath, abstract]
		end
		return query_result
	end#end-func

	def find_tf(docid, id)
		index = @dexfile.get_index(docid)#可以优化cache
		index[:my_index][id]
	end
end#enc-class
