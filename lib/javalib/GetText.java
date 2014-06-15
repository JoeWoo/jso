package wujian;

import java.io.FileInputStream;


//HSSF classes for xls
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;

//XSSF classes for xlsx
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

//OPCPackage for OOML that XWPF and XSLF will use
import org.apache.poi.openxml4j.opc.OPCPackage;

//Classes for doc and docx
import org.apache.poi.hwpf.extractor.WordExtractor;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;

//Classes for ppt and pptx
import org.apache.poi.hslf.extractor.PowerPointExtractor;
import org.apache.poi.xslf.extractor.XSLFPowerPointExtractor;

public class GetText {
	
	 public String getDOC(String filepath)throws Exception {
		 FileInputStream is = new FileInputStream(filepath);
		 POIFSFileSystem pf = new POIFSFileSystem(is);
		 WordExtractor word = new WordExtractor(pf);
		 String	text = word.getText();
		 is.close();
		 return text;
	 }
	 
	 public String getDOCX(String filepath)throws Exception {
		 FileInputStream is = new FileInputStream(filepath);
		 OPCPackage ocp =  OPCPackage.open(is);
		 XWPFWordExtractor word = new XWPFWordExtractor(ocp);
		 String text = word.getText();
		 is.close();
		 return text;
	 }
	 
	 public String getXLS(String filepath)throws Exception {
		 FileInputStream is = new FileInputStream(filepath);
		 HSSFWorkbook wb = new HSSFWorkbook(is);
		 StringBuffer text = new StringBuffer();
		 int sheets = wb.getNumberOfSheets();
		 for (int i = 0 ; i<sheets ; i++ ) {
		 	HSSFSheet sheet = wb.getSheetAt(i);
		 	int rows = sheet.getPhysicalNumberOfRows();
		 	text.append(wb.getSheetName(i));
		 	for (int j = 0 ; j<rows ; j++ ) {
		 		HSSFRow row = sheet.getRow(j);
		 		if (row == null){
		 			continue;
		 		}
		 		int cells = row.getPhysicalNumberOfCells();
		 		for (int k = 0; k<cells ; k++ ) {
		 			HSSFCell cell = row.getCell(k);
		 			if (cell.getCellType()==HSSFCell.CELL_TYPE_STRING){
		 				text.append(cell.getStringCellValue());
		 			}
		 		}
		 	}
		 }
		 
		 is.close();
		 return text.toString();
	 }
	 
	 public String getXLSX(String filepath)throws Exception {
		 FileInputStream is = new FileInputStream(filepath);
		 XSSFWorkbook wb = new XSSFWorkbook(is);
		 StringBuffer text = new StringBuffer();
		 int sheets = wb.getNumberOfSheets();
		 for (int i = 0 ; i<sheets ; i++ ) {
		 	XSSFSheet sheet = wb.getSheetAt(i);
		 	int rows = sheet.getPhysicalNumberOfRows();
		 	text.append(wb.getSheetName(i));
		 	for (int j = 0 ; j<rows ; j++ ) {
		 		XSSFRow row = sheet.getRow(j);
		 		if (row == null){
		 			continue;
		 		}
		 		int cells = row.getPhysicalNumberOfCells();
		 		for (int k = 0; k<cells ; k++ ) {
		 			XSSFCell cell = row.getCell(k);
		 			if (cell.getCellType()==HSSFCell.CELL_TYPE_STRING){
		 				text.append(cell.getStringCellValue());
		 			}
		 		}
		 	}
		 }
		 is.close();
		 return text.toString();
	 }
	 
	 public String getPPT(String filepath)throws Exception {
		 FileInputStream is = new FileInputStream(filepath);
		 PowerPointExtractor m = new PowerPointExtractor(is);
		 String text = m.getText(true,true);
		 is.close();
		 return text;
	 }
	 
	 public String getPPTX(String filepath)throws Exception {
		 FileInputStream is = new FileInputStream(filepath);
		 OPCPackage ocp =  OPCPackage.open(is);
		 XSLFPowerPointExtractor pptx = new XSLFPowerPointExtractor(ocp);
		 String text = pptx.getText(true,true);
		 is.close();
		 return text;
	 }
}