#
# Main
#
require './document'
require './index'
require './indexer'
require './searcher'
require './encode_helper'
include EncodeHelper




# ask the path of target files to be indexed
print "please type in  the target file folder path (like'./txt/'):"
$stdout.flush
txt_dir = gets
txt_dir.chop! #delete the gets string tail`s '\n\t'

txt_dir = "./txt/" if txt_dir.strip.empty?#default path


# index: scan all the TXT files and index it
index = Index.new
indexer = Indexer.new(index)
print "\n"
dirp = Dir.open(txt_dir)
for f in dirp
  case f
  when /\.txt/
    doc = DocumentFile.new(txt_dir + f)
    print "Processing [#{doc.name}] file.", "\n"
    indexer.add(doc)
  end
end
dirp.close
#pf = File.new("invertedIndex.yaml","w+")
#pf.write(index.invertedIndex.to_yaml)
print "\nIndex completed! Documents: #{index.total_number_of_documents} Terms: #{index.total_number_of_terms}", "\n"



userinput=[" "]
searcher = Searcher.new(index)
until userinput.empty?
  print "\n", "Search:"
  $stdout.flush
  #get and analyse query line to keywords
  str = gets()
  str=segment_chinese_words(str)
  str = toutf8(str)
  userinput=str.scan(/([\u4e00-\u9fa5]+|[\w]+)/)#get chinese char and english word
  keywords=Array.new
  userinput.each{ |wordarray|  wordarray.each{|word| keywords << word.to_s.downcase }  }
  puts keywords

  #search
  result = searcher.search(keywords)

  #sort by rank
  result = result.sort {|a, b| b[1][1] <=> a[1][1]}

  #puts the rankpage
  result.each do |key, docinfo|
    doc = docinfo[0]
    rank = docinfo[1]
    print "file: #{doc.name}  [rank: #{rank}] ", "\n"
  end

end#end-until
