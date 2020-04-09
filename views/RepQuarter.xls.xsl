<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	 xmlns="urn:schemas-microsoft-com:office:spreadsheet"
	 xmlns:o="urn:schemas-microsoft-com:office:office"
	 xmlns:x="urn:schemas-microsoft-com:office:excel"
	 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
	 xmlns:html="http://www.w3.org/TR/REC-html40">

<xsl:output method="xml" indent="yes"/> 

<xsl:variable name="DT_INT" select="'0'"/>
<xsl:variable name="DT_INT_UNSIGNED" select="'1'"/>
<xsl:variable name="DT_STRING" select="'2'"/>
<xsl:variable name="DT_FLOAT_UNSIGNED" select="'3'"/>
<xsl:variable name="DT_FLOAT" select="'4'"/>
<xsl:variable name="DT_CUR_RUR" select="'5'"/>
<xsl:variable name="DT_CUR_USD" select="'6'"/>
<xsl:variable name="DT_BOOL" select="'7'"/>
<xsl:variable name="DT_TEXT" select="'8'"/>
<xsl:variable name="DT_DATETIME" select="'9'"/>
<xsl:variable name="DT_DATE" select="'10'"/>
<xsl:variable name="DT_TIME" select="'11'"/>
<xsl:variable name="DT_OBJECT" select="'12'"/>
<xsl:variable name="DT_FILE" select="'13'"/>
<xsl:variable name="DT_PWD" select="'14'"/>
<xsl:variable name="DT_EMAIL" select="'15'"/>
<xsl:variable name="DT_ENUM" select="'16'"/>

<!-- default widths for data types in px-->
<xsl:variable name="DEF_WIDTH_DATE" select="100"/>
<xsl:variable name="DEF_WIDTH_TIME" select="100"/>
<xsl:variable name="DEF_WIDTH_DATETIME" select="125"/>
<xsl:variable name="DEF_WIDTH_INT" select="65"/>
<xsl:variable name="DEF_WIDTH_DOUBLE" select="50"/>
<xsl:variable name="DEF_WIDTH_FILE" select="230"/>
<xsl:variable name="DEF_COL_WIDTH" select="100"/>

<xsl:variable name="EXCEl_STYLE_ID_STRING" select="'s21'"/>
<xsl:variable name="EXCEl_STYLE_ID_INT" select="'s26'"/>
<xsl:variable name="EXCEl_STYLE_ID_MONEY" select="'s23'"/>
<xsl:variable name="EXCEl_STYLE_ID_FLOAT" select="'s27'"/>
<xsl:variable name="EXCEl_STYLE_ID_DATETIME" select="'s24'"/>
<xsl:variable name="EXCEl_STYLE_ID_DATE" select="'s25'"/>

<xsl:variable name="EXCEl_DT_INT" select="'Number'"/>
<xsl:variable name="EXCEl_DT_FLOAT" select="'Number'"/>
<xsl:variable name="EXCEl_DT_STRING" select="'String'"/>
<xsl:variable name="EXCEl_DT_DATETIME" select="'DateTime'"/>
<xsl:variable name="EXCEl_DT_DATE" select="'Date'"/>

<xsl:template name="string-replace-all">
  <xsl:param name="text" />
  <xsl:param name="replace" />
  <xsl:param name="by" />
  <xsl:choose>
    <xsl:when test="contains($text, $replace)">
      <xsl:value-of select="substring-before($text,$replace)" />
      <xsl:value-of select="$by" />
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text"
        select="substring-after($text,$replace)" />
        <xsl:with-param name="replace" select="$replace" />
        <xsl:with-param name="by" select="$by" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="format_date">
	<xsl:param name="val"/>
	<xsl:param name="formatStr"/>
	<xsl:choose>
		<xsl:when test="string-length($val)=10">
			<xsl:variable name="val_year" select="substring-before($val,'-')"/>
			<xsl:variable name="part_month" select="substring-after($val,'-')"/>
			<xsl:variable name="val_month" select="substring-before($part_month,'-')"/>
			<xsl:variable name="part_date" select="substring-after($part_month,'-')"/>
			<xsl:variable name="val_date" select="$part_date"/>
			<xsl:value-of select="concat($val_date,'/',$val_month,'/',$val_year)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$val" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Main template-->
<xsl:template match="/">
	<xsl:processing-instruction
		name="mso-application">progid="Excel.Sheet"
	</xsl:processing-instruction>

	<Workbook 
	 xmlns="urn:schemas-microsoft-com:office:spreadsheet"
	 xmlns:o="urn:schemas-microsoft-com:office:office"
	 xmlns:x="urn:schemas-microsoft-com:office:excel"
	 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
	 xmlns:html="http://www.w3.org/TR/REC-html40">

		<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
			<Author><xsl:value-of select="page/user_details/@descr"/></Author>
			<LastAuthor></LastAuthor>
			<Created><xsl:value-of select="page/@created"/></Created>
			<Company><xsl:value-of select="page/@firm"/></Company>
			<Version>10.2625</Version>
		</DocumentProperties>
		<OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
			<DownloadComponents/>
			<LocationOfComponents HRef=""/>
		</OfficeDocumentSettings>
	 
		<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
			<WindowHeight>10485</WindowHeight>
			<WindowWidth>20955</WindowWidth>
			<WindowTopX>240</WindowTopX>
			<WindowTopY>15</WindowTopY>
			<RefModeR1C1/>
			<ProtectStructure>False</ProtectStructure>
			<ProtectWindows>False</ProtectWindows>
		</ExcelWorkbook>
		<Styles>
			<Style ss:ID="Default" ss:Name="Normal">
				<Alignment ss:Vertical="Bottom"/>
				<Borders/>
				<Font ss:FontName="Arial Cyr" x:CharSet="204"/>
				<Interior/>
				<NumberFormat/>
				<Protection/>
			</Style>
			<Style ss:ID="s21">
				<Font ss:FontName="Arial Cyr" x:CharSet="204"/>
			</Style>
			<Style ss:ID="s22">
				<Font ss:FontName="Arial Cyr" x:CharSet="204" ss:Bold="1"/>
				<Interior ss:Color="#C0C0C0" ss:Pattern="Solid"/>
			</Style>
			<Style ss:ID="s23">
				<NumberFormat ss:Format="Currency"/>
			</Style>
			<Style ss:ID="s27">
				<NumberFormat/>
			</Style>			
			<Style ss:ID="s24">
				<NumberFormat ss:Format="dd/mm/yy\ h:mm;@"/>
			</Style>			
			<Style ss:ID="s25">
				<NumberFormat ss:Format="dd/mm/yy;@"/>
			</Style>			
			<Style ss:ID="s26">
				<NumberFormat ss:Format="0"/>
			</Style>			
			
		</Styles>
		
		<!-- sheets -->
		<xsl:apply-templates select="document/model[@id = 'RepQuarter_Model']"/>
		
	</Workbook>
</xsl:template>

<!-- table -->
<xsl:template match="model[@id = 'RepQuarter_Model']">
	<xsl:variable name="build_type_count" select="count(/document/model[@id='BuildType_Model']/row)"/>
	<xsl:variable name="expertize_type_count" select="4"/>				
	<Worksheet ss:Name="Rep{position()}">
		<Table ss:ExpandedColumnCount="{9+$build_type_count+$expertize_type_count+4}" ss:ExpandedRowCount="{9+$build_type_count+$expertize_type_count+4+1}" x:FullColumns="1"
		   x:FullRows="1">		   	
		   	<Row>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">№</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">№ эксп.заключ.</Data>
				</Cell>
				<Cell ss:StyleID="s25">
					<Data ss:Type="Date">Дата пост.</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">Заказчик</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">Объект строительства</Data>
				</Cell>
				<Cell ss:StyleID="s25">
					<Data ss:Type="Date">Дата нач.работ</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">Номер первичного заключ.</Data>
				</Cell>
				<Cell ss:StyleID="s25">
					<Data ss:Type="Date">Дата отриц.зак.</Data>
				</Cell>
				<Cell ss:StyleID="s25">
					<Data ss:Type="Date">Дата положит.зак.</Data>
				</Cell>
				<xsl:for-each select="/document/model[@id='BuildType_Model']/row">
					<Cell ss:StyleID="s21">
						<Data ss:Type="String"><xsl:value-of select="name"/></Data>
					</Cell>				
				</xsl:for-each>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">ПД</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">РИИ</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">ПДиРИИ</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">Достоверность</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">ПД и Достоверность</Data>
				</Cell>
				<Cell ss:StyleID="s21">
					<Data ss:Type="String">ПД, РИИ, Достоверность</Data>
				</Cell>
			
				<Cell ss:StyleID="s23">
					<Data ss:Type="Currency">Вход.см.стоимость</Data>
				</Cell>
				<Cell ss:StyleID="s23">
					<Data ss:Type="Currency">Вход.реком.см.стоимость</Data>
				</Cell>
				<Cell ss:StyleID="s23">
					<Data ss:Type="Currency">Тек.см.стоимость</Data>
				</Cell>
				<Cell ss:StyleID="s23">
					<Data ss:Type="Currency">Тек.реком.см.стоимость</Data>
				</Cell>
			</Row>
			
			<xsl:apply-templates select="row"/>
		</Table>
		<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
			<PageSetup>
				<PageMargins x:Bottom="0.984251969" x:Left="0.78740157499999996"
				x:Right="0.78740157499999996" x:Top="0.984251969"/>
			</PageSetup>
			<Print>
				<ValidPrinterInfo/>
				<PaperSizeIndex>9</PaperSizeIndex>
				<HorizontalResolution>600</HorizontalResolution>
				<VerticalResolution>0</VerticalResolution>
			</Print>
			<Selected/>
			<ProtectObjects>False</ProtectObjects>
			<ProtectScenarios>False</ProtectScenarios>
		</WorksheetOptions>
	</Worksheet>
</xsl:template>

<!-- table row
сохраним порядок из заголовка модели
пройдем циклом по заголовку
хотя данные могут быть выбраны в другом порядке
-->
<xsl:template match="row">
	<Row>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String"><xsl:value-of select="ord"/></Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String"><xsl:value-of select="expertise_result_number"/></Data>
		</Cell>
		<Cell ss:StyleID="s25">
			<Data ss:Type="Date">
			<xsl:call-template name="format_date">
				<xsl:with-param name="val" select="date/node()"/>
				<xsl:with-param name="fromatStr" select="''"/>
			</xsl:call-template>																									
			</Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String"><xsl:value-of select="customer/node()"/></Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String"><xsl:value-of select="constr_name/node()"/></Data>
		</Cell>
		<Cell ss:StyleID="s25">
			<Data ss:Type="Date">
			<xsl:call-template name="format_date">
				<xsl:with-param name="val" select="work_start_date/node()"/>
				<xsl:with-param name="fromatStr" select="''"/>
			</xsl:call-template>																									
			</Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String"><xsl:value-of select="primary_expertise_result_number/node()"/></Data>
		</Cell>
		<Cell ss:StyleID="s25">
			<Data ss:Type="Date">
			<xsl:if test="expertise_result='negative'">
			<xsl:call-template name="format_date">
				<xsl:with-param name="val" select="expertise_result_date/node()"/>
				<xsl:with-param name="fromatStr" select="''"/>
			</xsl:call-template>																									
			</xsl:if>
			</Data>
		</Cell>
		<Cell ss:StyleID="s25">
			<Data ss:Type="Date">
			<xsl:if test="expertise_result='positive'">
			<xsl:call-template name="format_date">
				<xsl:with-param name="val" select="expertise_result_date/node()"/>
				<xsl:with-param name="fromatStr" select="''"/>
			</xsl:call-template>																									
			</xsl:if>
			</Data>
		</Cell>
		<xsl:variable name="build_type_id" select="build_type_id"/>
		<xsl:for-each select="/document/model[@id='BuildType_Model']/row">			
			<Cell ss:StyleID="s21">			
				<Data ss:Type="String">
				<xsl:if test="id=$build_type_id">V</xsl:if>
				</Data>
			</Cell>				
		</xsl:for-each>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String">
			<xsl:if test="expertise_type='pd'">V</xsl:if>
			</Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String">
			<xsl:if test="expertise_type='eng_survey'">V</xsl:if>
			</Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String">
			<xsl:if test="expertise_type='pd_eng_survey'">V</xsl:if>
			</Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String">
			<xsl:if test="expertise_type='cost_eval_validity' or cost_eval_validity='true'">V</xsl:if>
			</Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String">
			<xsl:if test="expertise_type='cost_eval_validity_pd'">V</xsl:if>
			</Data>
		</Cell>
		<Cell ss:StyleID="s21">
			<Data ss:Type="String">
			<xsl:if test="expertise_type='cost_eval_validity_pd_eng_survey'">V</xsl:if>
			</Data>
		</Cell>
		
		<Cell ss:StyleID="s23">
			<Data ss:Type="String"><xsl:value-of select="in_estim_cost/node()"/></Data>
		</Cell>
		<Cell ss:StyleID="s23">
			<Data ss:Type="Currency"><xsl:value-of select="in_estim_cost_recommend/node()"/></Data>
		</Cell>
		<Cell ss:StyleID="s23">
			<Data ss:Type="Currency"><xsl:value-of select="cur_estim_cost/node()"/></Data>
		</Cell>
		<Cell ss:StyleID="s23">
			<Data ss:Type="Currency"><xsl:value-of select="cur_estim_cost_recommend/node()"/></Data>
		</Cell>
	</Row>
</xsl:template>


</xsl:stylesheet>
