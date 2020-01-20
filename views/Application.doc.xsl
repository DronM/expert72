<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml">

<xsl:output method="xml" indent="yes" />

<xsl:template match="/">
	<xsl:processing-instruction name="mso-application">
		<xsl:text>progid="Word.Document"</xsl:text>
	</xsl:processing-instruction>
	
	<w:wordDocument>
		<w:styles>
			<!-- P1 center text -->
			<w:style w:styleId="P1" w:type="paragraph">
				<w:basedOn w:val="Standard"/>
				<w:name w:val="P1"/>
				<w:hidden w:val="on"/>
				<w:pPr>
					<w:adjustRightInd w:val="off"/>
					<w:jc w:val="center"/>
					<w:spacing/>
					<w:ind/>
					<w:widowControl w:val="off"/>
					<w:pBdr/>
					<w:ind/>
				</w:pPr>
				<w:rPr>
					<w:sz w:val="32"/>
					<w:b/>
				</w:rPr>
			</w:style>
			<!-- P2 right text -->
			<w:style w:styleId="P2" w:type="paragraph">
				<w:basedOn w:val="Standard"/>
				<w:name w:val="P2"/>
				<w:hidden w:val="on"/>
				<w:pPr>
					<w:adjustRightInd w:val="off"/>
					<w:jc w:val="right"/>
					<w:spacing/>
					<w:ind w:left="4535,4331" w:right="0" w:first-line="0"/>
					<w:widowControl w:val="off"/>
					<w:pBdr/>
					<w:ind/>
				</w:pPr>
				<w:rPr>
					<w:b/>
				</w:rPr>
			</w:style>

			<!-- P3 ordinary text -->
			<w:style w:styleId="P3" w:type="paragraph">
				<w:basedOn w:val="Standard"/>
				<w:name w:val="P3"/>
				<w:hidden w:val="on"/>
				<w:pPr>
					<w:adjustRightInd w:val="off"/>
					<w:jc w:val="left"/>
					<w:spacing/>
					<w:ind/>
					<w:widowControl w:val="off"/>
					<w:pBdr/>
					<w:ind/>
				</w:pPr>
				<w:rPr>
					<w:b/>
				</w:rPr>
			</w:style>
			
			<!-- P4 BIG text -->
			<w:style w:styleId="P4" w:type="paragraph">
				<w:basedOn w:val="Standard"/>
				<w:name w:val="P4"/>
				<w:hidden w:val="on"/>
				<w:pPr>
					<w:adjustRightInd w:val="off"/>
					<w:jc w:val="center"/>
					<w:spacing/>
					<w:ind/>
					<w:widowControl w:val="off"/>
					<w:pBdr/>
					<w:ind/>
				</w:pPr>
				<w:rPr>
					<w:sz w:val="32"/>
					<w:b/>
				</w:rPr>
			</w:style>
			
		</w:styles>
	
		<w:body>
			<xsl:apply-templates select="document/model" />
		</w:body>
	</w:wordDocument>
</xsl:template>

<xsl:template match="model[@id='ModelServResponse']">
	<xsl:if test="not(number(row/result)=0)">
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P2"/>
		</w:pPr>	
		<w:r>
			<w:t>
				<xsl:value-of select="row/descr"/>
			</w:t>
		</w:r>
	</w:p>
	</xsl:if>
</xsl:template>

<xsl:template match="model[@id='ApplicationPrint_Model']">
	<!-- ******************* Заголовок  *******************************-->
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P4"/>
		</w:pPr>	
		<w:r>
			<w:t>
				--- НЕОБХОДИМО ЗАМЕНИТЬ ЭТО ТЕКСТ на логотипы, картинки и т.д ---
			</w:t>
		</w:r>
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P4"/>
		</w:pPr>	
		<w:r>
			<w:t></w:t>
		</w:r>
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P4"/>
		</w:pPr>	
		<w:r>
			<w:t></w:t>
		</w:r>
	</w:p>
	<!-- ******************* Заголовок  *******************************-->
	

	<!-- *************** Кому от кого *******************************-->
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P2"/>
		</w:pPr>	
		<w:r>
			<w:t>
				<xsl:value-of select="concat(row/boss_post_dat,' ',row/office_rod,' ',row/boss_name_dat)"/>
			</w:t>
		</w:r>
		<w:r>
			<w:t>
				<xsl:choose>
				<xsl:when test="row/applicant/client_type='enterprise'">
				<xsl:value-of select="concat('от  ',row/applicant/person_head_post_rod,' ',row/applicant/org_name_rod,' ',row/applicant/person_head_name_rod)"/>
				</xsl:when>
				<xsl:when test="row/applicant/client_type='pboul'">
				<xsl:value-of select="concat('от  индивидуального предпринимателя ',row/applicant/org_name_rod)"/>
				</xsl:when>
				<xsl:otherwise>
				<xsl:value-of select="concat('от  ',row/applicant/org_name_rod)"/>
				</xsl:otherwise>
				</xsl:choose>
			</w:t>
		</w:r>
	</w:p>
	<!-- *************** Кому от кого *******************************-->
	
	<!-- *************** Заголовок **********************-->
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P1"/>
		</w:pPr>	
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P1"/>
		</w:pPr>	
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P1"/>
		</w:pPr>	
	</w:p>
	
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P1"/>
		</w:pPr>	
		<w:r>
			<w:t>
				Заявление № <xsl:call-template name="doc_number"/> от <xsl:value-of select="row/date_descr"/>
			</w:t>
		</w:r>
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P1"/>
		</w:pPr>	
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P1"/>
		</w:pPr>	
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P1"/>
		</w:pPr>	
	</w:p>
	<!-- *************** Заголовок **********************-->
	
	
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P3"/>
		</w:pPr>	
		<w:r>
			<w:t>
	
				<xsl:call-template name="doc_head"/>
			</w:t>
		</w:r>
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P3"/>
		</w:pPr>	
		<w:r>
			<w:t>
	
				<xsl:value-of select="row/constr_name"/>,
			</w:t>
		</w:r>
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P3"/>
		</w:pPr>	
		<w:r>
			<w:t>
	
				по адресу <xsl:value-of select="row/constr_address"/>
			</w:t>
		</w:r>
	</w:p>
	<w:p>
		<w:pPr>
			<w:pStyle w:val="P3"/>
		</w:pPr>	
		<w:r>
			<w:t>
			</w:t>
		</w:r>
	</w:p>
	
	<!-- Свойства -->			
	<w:tbl
		xmlns:fo="urn:oasis:names:tc:opendocument:
		xmlns:xsl-fo-compatible:1.0">
		<w:tblPr>
			<w:tblStyle w:val="Таблица1"/>
			<w:tblW w:w="9572,0942" w:type="dxa"/>
			<w:tblInd w:w="-108,297" w:type="dxa"/>
			<w:jc w:val="left"/>
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="4785,4801"/>
			<w:gridCol w:w="4786,6141"/>
		</w:tblGrid>
		
		<xsl:call-template name="show_param_odd">
			<xsl:with-param name="n" select="'Вид объекта капитального строительства:'"/>
			<xsl:with-param name="v" select="row/construction_types_descr"/>
		</xsl:call-template>
		<xsl:call-template name="show_param_even">
			<xsl:with-param name="n" select="'Источник финансирования:'"/>
			<xsl:with-param name="v" select="row/fund_sources_descr"/>
		</xsl:call-template>
		<xsl:call-template name="show_param_odd">
			<xsl:with-param name="n" select="'Размер финансирования:'"/>
			<xsl:with-param name="v" select="row/fund_percent"/>%
		</xsl:call-template>
		<xsl:call-template name="show_param_even">
			<xsl:with-param name="n" select="'Стоимость изгот. ПД и материалов инженерных изысканий в ценах 2001 года (руб.):'"/>
			<xsl:with-param name="v" select="row/total_cost_eval"/>
		</xsl:call-template>
		
	</w:tbl>
	
</xsl:template>

<xsl:template name="doc_head">
	<xsl:choose>
	<xsl:when test="row/expertise_type='pd'"><xsl:text>Просим Вас провести государственную экспертизу проектной документации гарантируется.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='eng_survey'"><xsl:text>Просим Вас провести государственную экспертизу результатов инженерных изысканий.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='cost_eval_validity'"><xsl:text>Просим Вас провести государственную экспертизу проверки достоверености сметной стоимости.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='cost_eval_validity_pd'"><xsl:text>Просим Вас провести государственную экспертизу проектной документации и экспертизу проверки достоверености сметной стоимости.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='cost_eval_validity_eng_survey'"><xsl:text>Просим Вас провести государственную экспертизы результатов инженерных изысканий и экспертизу проверки достоверености сметной стоимости.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='cost_eval_validity_pd_eng_survey'"><xsl:text>Просим Вас провести государственную экспертизы проектной документации, экспертизу результатов инженерных изысканий и экспертизу проверки достоверености сметной стоимости.</xsl:text></xsl:when>
	<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="doc_number">
	<xsl:value-of select="row/id"/>
</xsl:template>

<xsl:template name="show_param_odd">
	<xsl:param name="n"/>
	<xsl:param name="v"/>
	<w:tr>
		<w:trPr/>
		<w:tc>
			<w:tcPr>
				<w:tcW w:type="dxa" w:w="4785,4801"/>
				<w:shd w:val="solid" w:color="cccccc"/>
				<w:tcMar>
					<w:top w:type="dxa" w:w="0"/>
					<w:bottom w:type="dxa" w:w="0"/>
					<w:left w:type="dxa" w:w="108,297"/>
					<w:right w:type="dxa" w:w="108,297"/>
				</w:tcMar>
				<w:tcBorders>
					<w:top w:val="none" w:sz="0" w:color="auto"/>
					<w:bottom w:val="single" w:sz="48" w:color="ffffff"/>
					<w:left w:val="none" w:sz="0" w:color="auto"/>
					<w:right w:val="none" w:sz="0" w:color="auto"/>
				</w:tcBorders>
			</w:tcPr>
			<w:p>
				<w:pPr>
					<w:pStyle w:val="P3"/>
				</w:pPr>
				<w:r>
					<w:t><xsl:value-of select="n"/></w:t>
				</w:r>
			</w:p>
		</w:tc>
		<w:tc>
			<w:tcPr>
				<w:tcW w:type="dxa" w:w="4786,6141"/>
				<w:shd w:val="solid" w:color="cccccc"/>
				<w:tcMar>
					<w:top w:type="dxa" w:w="0"/>
					<w:bottom w:type="dxa" w:w="0"/>
					<w:left w:type="dxa" w:w="108,297"/>
					<w:right w:type="dxa" w:w="108,297"/>
				</w:tcMar>
				<w:tcBorders>
					<w:top w:val="none" w:sz="0" w:color="auto"/>
					<w:bottom w:val="single" w:sz="48" w:color="ffffff"/>
					<w:left w:val="single" w:sz="48" w:color="ffffff"/>
					<w:right w:val="none" w:sz="0" w:color="auto"/>
				</w:tcBorders>
			</w:tcPr>
			<w:p>
				<w:pPr>
					<w:pStyle w:val="P3"/>
				</w:pPr>
				<w:r>
					<w:t><xsl:value-of select="v"/></w:t>
				</w:r>
			</w:p>
		</w:tc>
	</w:tr>

</xsl:template>

<xsl:template name="show_param_even">
	<xsl:param name="n"/>
	<xsl:param name="v"/>
	<w:tr>
		<w:trPr/>
		<w:tc>
			<w:tcPr>
				<w:tcW w:type="dxa" w:w="4785,4801"/>
				<w:shd w:val="solid" w:color="f2f2f2"/>
				<w:tcMar>
					<w:top w:type="dxa" w:w="0"/>
					<w:bottom w:type="dxa" w:w="0"/>
					<w:left w:type="dxa" w:w="108,297"/>
					<w:right w:type="dxa" w:w="108,297"/>
				</w:tcMar>
				<w:tcBorders>
					<w:top w:val="single" w:sz="48" w:color="ffffff"/>
					<w:bottom w:val="none" w:sz="0" w:color="auto"/>
					<w:left w:val="none" w:sz="0" w:color="auto"/>
					<w:right w:val="none" w:sz="0" w:color="auto"/>
				</w:tcBorders>
			</w:tcPr>
			<w:p>
				<w:pPr>
					<w:pStyle w:val="Standard"/>
				</w:pPr>
				<w:r>
					<w:t><xsl:value-of select="n"/></w:t>
				</w:r>
			</w:p>
		</w:tc>
		<w:tc>
			<w:tcPr>
				<w:tcW w:type="dxa" w:w="4786,6141"/>
				<w:shd w:val="solid" w:color="f2f2f2"/>
				<w:tcMar>
					<w:top w:type="dxa" w:w="0"/>
					<w:bottom w:type="dxa" w:w="0"/>
					<w:left w:type="dxa" w:w="108,297"/>
					<w:right w:type="dxa" w:w="108,297"/>
				</w:tcMar>
				<w:tcBorders>
					<w:top w:val="single" w:sz="48" w:color="ffffff"/>
					<w:bottom w:val="none" w:sz="0" w:color="auto"/>
					<w:left w:val="single" w:sz="48" w:color="ffffff"/>
					<w:right w:val="none" w:sz="0" w:color="auto"/>
				</w:tcBorders>
			</w:tcPr>
			<w:p>
				<w:pPr>
					<w:pStyle w:val="Standard"/>
				</w:pPr>
				<w:r>
					<w:t><xsl:value-of select="v"/></w:t>
				</w:r>
			</w:p>
		</w:tc>
	</w:tr>
	
</xsl:template>

<!--
<xsl:template match="Course">
	<w:p>
		<w:r>
			<w:t>
				<xsl:value-of select="@Number" />, <xsl:value-of select="Title"/>
			</w:t>
		</w:r>
	</w:p>
</xsl:template>
-->

</xsl:stylesheet>
