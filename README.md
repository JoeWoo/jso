# jso
jso is a simple Information Retrieval App for chinese documents with ruby.

this search engine based on **Vector Space Model**

the index will build every run time , it exist in the memory not in disk

run system:
linux & ruby2.0p0 


=======
include component:
ChineseWordSegmentation system: [NLPIR_for_ruby_linux_api](https://github.com/JoeWoo/NLPIR_for_ruby_linux_api)

rubygem for encoding: rchardet19

## How to use
	ruby jso.rb

if you don`t have rchardet19 use:

	gem install rchardet19
	ruby jso.rb
