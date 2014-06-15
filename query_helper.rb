# encoding: UTF-8
#!/usr/bin/ruby
# @Author: wujian
# @Date:   2014-05-09 14:45:23
# @Last Modified by:   wujian
# @Last Modified time: 2014-05-17 14:20:38
require File.dirname(__FILE__)+"/nlpir.rb"
require File.dirname(__FILE__)+"/tyccl.rb"

class  QueryHelper
	def self.process(q,invertedIndex)

		ids_list = []
		noun_ids_list = []
		noun_str_list = []
		wordpos_list = Nlpir.seg(q,NLPIR_TRUE)

		wordpos_list.each{  |wordpos|
			i = wordpos.rindex('/')
			pos = wordpos[i+1..-1]
			word = wordpos[0..i-1]
			id = -1
			if  Nlpir.core_words_exist?(word) == false
				id = (Nlpir.get_core_words_size() +1)
				Nlpir.set_core_words(word, id)
			else
				id =  Nlpir.get_core_words_id(word)
			end
			if pos == 'n'
				noun_ids_list << id
				noun_str_list << word
			end
			ids_list << id
		}

		##信息标引 标引频数
		most_term = 0
		most_term_times = 0

		query_map = {}
		ids_list.each do  |term|
			tmp2 = query_map[term]
			if tmp2.nil?
				query_map[term] = 1
			else
				query_map[term]+=1
			end

			tmp3 = query_map[term]
			if tmp3 > most_term_times
				most_term_times = tmp3
				most_term = term
			end
		end
		#  计算初步weight
		query_map.each do |id, weight|
			query_map[id]=	(0.5 + ((0.5 * Float(weight)) / (most_term_times * Float(weight))))
		end
		# 名词同义扩展
		0.upto(noun_ids_list.size-1) do |i|
			similar = Tyccl.get_same(noun_str_list[i])
			select_similar = []
			if similar.nil? ==  false
				similar.flatten!
				select_similar = similar.sample(2)
			end
			if select_similar.nil?  == false
				select_similar.each do |term|
					find_result = Nlpir.get_core_words_id(term)
					if  find_result.nil? ==  false && query_map.has_key?(find_result)== false
						query_map[find_result] = query_map[noun_ids_list[i]]*0.2
					end
				end
			end
		end
		query_map
	end

end
