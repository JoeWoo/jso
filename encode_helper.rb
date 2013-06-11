require 'rchardet19'
require File.dirname(__FILE__)+"/NLPIR.rb"
include NLPIR

module EncodeHelper

  def segment_chinese_words(str)
    if NLPIR_Init(nil, UTF8_CODE )==NLPIR_FALSE
      puts "NLPIR_Init failed"
    end

    str = NLPIR_ParagraphProcess(str, ICT_POS_MAP_FIRST)
    str = str.to_s
    str.gsub!(/\/[\w]+[\s]/," ")
    NLPIR_Exit()
    return str
  end

  def toutf8(_string)
    cd = CharDet.detect(_string)
    if cd.confidence > 0.6
      _string.force_encoding(cd.encoding)
      _string.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
    end
    return  _string
  end

end
