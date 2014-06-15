# coding: utf-8
# = test class docfile_helper
# @Author: wujian
# @Date:   2014-05-03 12:47:37
# @Last Modified by:   wujian
# @Last Modified time: 2014-05-16 17:32:52



require 'minitest/autorun'
require File.expand_path('../../filetype_helper.rb', __FILE__)


class DocFile_HelperTest < MiniTest::Unit::TestCase #:nodoc:all
    def setup
        @dfh =  FiletypeHelper.new
    end

    def test_get_filetype
        assert_equal  "pdf",
            @dfh.get_filetype( "/home/dif/test/234fmn.pdf")
        assert_equal  "xls",
            @dfh.get_filetype( "/home/dif/test/234fmn.xls")
    end

    def test_all2text
        assert_equal 5695,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/test.pdf").size
        assert_equal 569,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/test.xls").size
        assert_equal 1645,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/test.xlsx").size
        assert_equal 1152,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/test.doc").size
        assert_equal 10703,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/test.docx").size
        assert_equal 1241,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/test.pptx").size
        assert_equal 1241,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/test.ppt").size
        assert_equal 4986,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/test.txt").size
        assert_equal 54797,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/LoadRunner压力测试&Selenium自动化测试工具使用说明（原创）.docx").size
        assert_equal 79,
            @dfh.all2text(File.dirname(__FILE__)+"/test_data/zhonto.xlsx").size
    end
end
