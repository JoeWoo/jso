require 'listen'
require 'rbconfig'
if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
  gem 'wdm', '>= 0.1.0'
end
require File.dirname(__FILE__)+"/db.rb"
paths = "'F:/tmp'"
db = DB.new
# listener = "Listen.to(#{paths}, only: /\.pdf|\.txt|\.doc|\.docx|\.xls|\.xlsx|\.ppt|\.pptx$/) do |modified, added, removed|
    
# end"



# Create a callback
callback = Proc.new do |modified, added, removed|
 puts "modified absolute path: #{modified}"
 puts "added absolute path: #{added}"
 puts "removed absolute path: #{removed}"
end
listener = eval"Listen.to(#{paths}, &callback)"
listener.start
sleep
