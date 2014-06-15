# encoding: UTF-8
# = Class to help parsing pdf doc docx ppt pptx xls xlsx filetype to pure text
# = based on Apache POI and Xpdf
# @Author: wujian
# @Date:   2014-05-01 18:48:09
# @Last Modified by:   wujian
# @Last Modified time: 2014-06-15 12:28:53
require "rjb"

class FiletypeHelper

	#import java class
	def  initialize()
		if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
			jars = Dir.glob(File.dirname(__FILE__)+"/lib/javalib/**/*.jar").join(';')
			Rjb::load(classpath=".;"+jars)
		elsif RbConfig::CONFIG['target_os'] =~ /linux/i
			jars = Dir.glob(File.dirname(__FILE__)+"/lib/javalib/**/*.jar").join(':')
			Rjb::load(classpath=".:"+jars)
		end

		# java file class
		#@FileInputStream = Rjb::import 'java.io.FileInputStream'

		# #HSSF classes for xls
		# @HSSFCell = Rjb::import 'org.apache.poi.hssf.usermodel.HSSFCell'
		# @HSSFRow = Rjb::import 'org.apache.poi.hssf.usermodel.HSSFRow'
		# @HSSFSheet = Rjb::import 'org.apache.poi.hssf.usermodel.HSSFSheet'
		# @HSSFWorkbook = Rjb::import 'org.apache.poi.hssf.usermodel.HSSFWorkbook'
		# @POIFSFileSystem = Rjb::import 'org.apache.poi.poifs.filesystem.POIFSFileSystem'

		# #XSSF classes for xlsx
		# @XSSFCell = Rjb::import 'org.apache.poi.xssf.usermodel.XSSFCell'
		# @XSSFRow = Rjb::import 'org.apache.poi.xssf.usermodel.XSSFRow'
		# @XSSFSheet = Rjb::import 'org.apache.poi.xssf.usermodel.XSSFSheet'
		# @XSSFWorkbook = Rjb::import 'org.apache.poi.xssf.usermodel.XSSFWorkbook'

		#OPCPackage for OOML that XWPF and XSLF will use
		# @OPCPackage = Rjb::import 'org.apache.poi.openxml4j.opc.OPCPackage'

		# #Classes for doc and docx
		# @WordExtractor = Rjb::import 'org.apache.poi.hwpf.extractor.WordExtractor'
		# @XWPFWordExtractor = Rjb::import 'org.apache.poi.xwpf.extractor.XWPFWordExtractor'

		# #Classes for ppt and pptx
		@GetText = Rjb::import 'wujian.GetText'
		# @PowerPointExtractor = Rjb::import 'org.apache.poi.hslf.extractor.PowerPointExtractor'
		# @XSLFPowerPointExtractor = Rjb::import 'org.apache.poi.xslf.extractor.XSLFPowerPointExtractor'
		@helper = @GetText.new()
	end

	def  all2text(filepath)
		filetype = get_filetype(filepath)
		begin
			text = self.send("#{filetype}2text",filepath)

			if text.encoding.to_s == 'GBK'
				text.force_encoding('utf-8')
			end
			#puts text
			text
		rescue Exception => e
			p e
			puts "文件格式不被支持！"
		end
	end


	def  get_filetype(filepath)
		i = filepath.rindex('.')
		filepath[i+1..-1]
	end

	def  can_process?(filename)
		['txt','pdf','doc','docx','xls','xlsx','ppt','pptx'].include?(get_filetype(filename))
	end

	def  txt2text(filepath)
		file = File.new(filepath)
		text = file.read()
		file.close()
		return text
	end

	def  pdf2text(filepath, noblank = true)
		begin
			temp ="./.temp.txt"
			require 'rbconfig'
			if RbConfig::CONFIG['target_os'] =~ /mswin|mingw|cygwin/i
				filepath.encode!('gbk')
				xpdf = File.dirname(__FILE__)+"/lib/Xpdf/pdftotext.exe"
				`#{xpdf} "#{filepath}"  #{temp}`
			elsif RbConfig::CONFIG['target_os'] =~ /bsd|dragonfly/i
			else
				xpdf = "pdftotext"
				`#{xpdf} "#{filepath}"  #{temp}`
			end
			file = File.new(temp)
			text  = file.read()
			file.close
			return text
		rescue
			return ""
		end
	end

	def  office2text(filepath)
		filetype = get_filetype(filepath)
		text = self.send("#{filetype}2text",filepath)
	end

	def  doc2text(filepath)
		begin
			text = @helper.getDOC(filepath)
			return text
		rescue
			return ""
		end
	end

	def  docx2text(filepath)
		begin
			text = @helper.getDOCX(filepath)
			return text
		rescue
			return ""
		end
	end

	def  xls2text(filepath)
		begin
			text = @helper.getXLS(filepath)
			return text
		rescue
			return ""
		end
	end

	def  xlsx2text(filepath)
		begin
			text = @helper.getXLSX(filepath)
			return  text
		rescue
			return ""
		end
	end

	def  ppt2text(filepath)
		begin
			text = @helper.getPPT(filepath)
			return text
		rescue
			return ""
		end
	end

	def  pptx2text(filepath)
		begin
			text = @helper.getPPTX(filepath)
			return text
		rescue
			return ""
		end
	end

end
