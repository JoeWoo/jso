# jso
jso is a simple Information Retrieval App for chinese documents by ruby language.

this search engine based on **Vector Space Model**

the index will be build at each run time , and it exists in memory not in disk

run system:
linux & ruby2.0.0p0 


=======
app include component:

1. ChineseWordSegmentation system: [NLPIR_for_ruby_linux_api](https://github.com/JoeWoo/NLPIR_for_ruby_linux_api)  

2. rubygem for encoding: rchardet19

## How to use
	ruby jso.rb

if you don`t have rchardet19 use:

	gem install rchardet19
	ruby jso.rb
