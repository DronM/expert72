<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" standalone="yes" encoding="utf-8" />

<xsl:template match="/">
	<w:document
		xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
		xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
		xmlns:o="urn:schemas-microsoft-com:office:office"
		xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
		xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
		xmlns:v="urn:schemas-microsoft-com:vml"
		xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
		xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
		xmlns:w10="urn:schemas-microsoft-com:office:word"
		xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
		xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
		xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
		xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
		xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
		xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
		xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" mc:Ignorable="w14 w15 wp14">
		<w:body>
			<xsl:apply-templates select="document/model" />
		</w:body>
	</w:document>	
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
	<!--************ Заменяемая шапка*************************** -->
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="0ADEBBEE" w14:textId="6BB3D52C">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:jc w:val="center" />
			<w:rPr>
				<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Calibri" w:cs="Calibri" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="52" />
				<w:szCs w:val="52" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Calibri" w:cs="Calibri" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="52" />
				<w:szCs w:val="52" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t xml:space="preserve">--- ВАША ШАПКА --- </w:t>
		</w:r>
	</w:p>
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="0A8EECA6" w14:textId="525ED15F">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:jc w:val="center" />
			<w:rPr>
				<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Calibri" w:cs="Calibri" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="52" />
				<w:szCs w:val="52" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
	</w:p>
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="5DFB63C4" w14:textId="46A49DCE">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:jc w:val="center" />
			<w:rPr>
				<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:eastAsia="Calibri" w:cs="Calibri" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="52" />
				<w:szCs w:val="52" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
	</w:p>
	<!--************ Заменяемая шапка*************************** -->
	
	
	<!--************ Кому от кого *************************** -->
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="2F118656" w14:textId="2B9C5AE8">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="4535" />
			<w:jc w:val="right" />
		</w:pPr>
		<w:proofErr w:type="spellStart" />
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:noProof w:val="0" />
				<w:sz w:val="19" />
				<w:szCs w:val="19" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t><xsl:value-of select="concat(row/boss_post_dat,' ',row/office_rod,' ',row/boss_name_dat)"/></w:t>
		</w:r>
		<w:proofErr w:type="spellEnd" />
	</w:p>
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="2F118656" w14:textId="2B9C5AE8">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="4535" />
			<w:jc w:val="right" />
		</w:pPr>
		<w:proofErr w:type="spellStart" />
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:noProof w:val="0" />
				<w:sz w:val="19" />
				<w:szCs w:val="19" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t><xsl:choose>
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
		<w:proofErr w:type="spellEnd" />
	</w:p>
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="62FAEC83" w14:textId="107F7FE6">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="4535" />
			<w:jc w:val="right" />
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:noProof w:val="0" />
				<w:sz w:val="19" />
				<w:szCs w:val="19" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
	</w:p>
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="02FAA1E2" w14:textId="717151DD">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="4535" />
			<w:jc w:val="right" />
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:noProof w:val="0" />
				<w:sz w:val="19" />
				<w:szCs w:val="19" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
	</w:p>
	<!--************ Кому от кого *************************** -->
	
	
	<!--************ Заявление *************************** -->
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="730F215F" w14:textId="6403829E">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="708" />
			<w:jc w:val="center" />
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="32" />
				<w:szCs w:val="32" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="32" />
				<w:szCs w:val="32" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t>Заявление № <xsl:call-template name="doc_number"/> от <xsl:value-of select="row/date_descr"/></w:t>
		</w:r>
	</w:p>
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="72E3572D" w14:textId="5A8C7879">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="708" />
			<w:jc w:val="center" />
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="32" />
				<w:szCs w:val="32" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
	</w:p>
	<!--************ Заявление *************************** -->
	
	<!--************ НАЧАЛО *************************** -->
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="4BCC0CBF" w14:textId="6EA77420">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="0" w:firstLine="708" />
			<w:jc w:val="left" />
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="32" />
				<w:szCs w:val="32" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="0" />
				<w:bCs w:val="0" />
				<w:noProof w:val="0" />
				<w:sz w:val="24" />
				<w:szCs w:val="24" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t xml:space="preserve"><xsl:call-template name="doc_head"/></w:t>
		</w:r>
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="0" />
				<w:bCs w:val="0" />
				<w:noProof w:val="0" />
				<w:sz w:val="24" />
				<w:szCs w:val="24" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t><xsl:value-of select="concat(' ',row/constr_name)"/>,</w:t>
		</w:r>
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="0" />
				<w:bCs w:val="0" />
				<w:noProof w:val="0" />
				<w:sz w:val="24" />
				<w:szCs w:val="24" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t>по адресу <xsl:value-of select="row/constr_address"/></w:t>
		</w:r>
		<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="586D9244" w14:textId="42EDD22E">
			<w:pPr>
				<w:pStyle w:val="Normal" />
				<w:ind w:left="0" w:firstLine="708" />
				<w:jc w:val="left" />
				<w:rPr>
					<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
					<w:b w:val="0" />
					<w:bCs w:val="0" />
					<w:noProof w:val="0" />
					<w:sz w:val="24" />
					<w:szCs w:val="24" />
					<w:lang w:val="ru-RU" />
				</w:rPr>
			</w:pPr>
		</w:p>		
	</w:p>
	<!--************ НАЧАЛО *************************** -->
	
	
	<!--*********************  Свойства ************************* -->
	<xsl:variable name="cost_eval" select="row/cost_eval_validity='t' or row/exp_cost_eval_validity='t'"/>
	<xsl:variable name="is_state_expertise" select="row/expertise_type='pd' or row/expertise_type='pd_eng_survey' or row/expertise_type='cost_eval_validity_pd'"/>		
	<xsl:variable name="is_state_expertise_colored">
		<xsl:choose>
		<xsl:when test="$cost_eval">0</xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="feature_colored">
		<xsl:choose>
		<xsl:when test="$cost_eval and $is_state_expertise">1</xsl:when>
		<xsl:when test="$cost_eval and not($is_state_expertise)">0</xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<w:tbl>
		<w:tblPr>
			<w:tblStyle w:val="PlainTable4" />
			<w:tblW w:w="0" w:type="auto" />
			<w:tblInd w:w="0" w:type="dxa" />
			<w:tblLayout w:type="fixed" />
			<w:tblLook w:val="06A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="4513" />
			<w:gridCol w:w="4513" />
		</w:tblGrid>
		<xsl:call-template name="show_param">
			<xsl:with-param name="n" select="'Вид объекта капитального строительства'"/>
			<xsl:with-param name="v" select="row/construction_types_descr"/>
			<xsl:with-param name="colored" select="'1'"/>
		</xsl:call-template>
		<xsl:call-template name="show_param">
			<xsl:with-param name="n" select="'Источник финансирования'"/>
			<xsl:with-param name="v" select="row/fund_sources_descr"/>
			<xsl:with-param name="colored" select="'0'"/>
		</xsl:call-template>
		<xsl:call-template name="show_param">
			<xsl:with-param name="n" select="'Размер финансирования'"/>
			<xsl:with-param name="v" select="concat(row/fund_percent,'%')"/>
			<xsl:with-param name="colored" select="'1'"/>
		</xsl:call-template>
		<xsl:call-template name="show_param">
			<xsl:with-param name="n" select="'Стоимость изгот. ПД и материалов инженерных изысканий в ценах 2001 года (руб.)'"/>
			<xsl:with-param name="v" select="row/total_cost_eval"/>
			<xsl:with-param name="colored" select="'0'"/>
		</xsl:call-template>
		<xsl:if test="$cost_eval">
			<xsl:call-template name="show_param">
				<xsl:with-param name="n" select="'Сметная или предполагаемая (предельная) стоимость объекта (тыс.руб.)'"/>
				<xsl:with-param name="v" select="row/limit_cost_eval"/>
				<xsl:with-param name="colored" select="'1'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$is_state_expertise">
			<xsl:call-template name="show_param">
				<xsl:with-param name="n" select="'Сведения об использовании (о причинах неиспользования) повторного использования проектной документации'"/>
				<xsl:with-param name="v" select="row/pd_usage_info"/>
				<xsl:with-param name="colored" select="$is_state_expertise_colored"/>
			</xsl:call-template>
		</xsl:if>		
	</w:tbl>
	<!--*********************  Свойства ************************* -->
	
	
	<!--*********************  ТЭП ************************* -->
	<xsl:call-template name="param_header">
		<xsl:with-param name="n" select="'Технико-экономические характеристики объекта'"/>
	</xsl:call-template>
	<w:tbl>
		<w:tblPr>
			<w:tblStyle w:val="PlainTable4" />
			<w:tblW w:w="0" w:type="auto" />
			<w:tblInd w:w="0" w:type="dxa" />
			<w:tblLayout w:type="fixed" />
			<w:tblLook w:val="06A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="4513" />
			<w:gridCol w:w="4513" />
		</w:tblGrid>	
		<xsl:apply-templates select="row/constr_technical_features"/>
	</w:tbl>
	<!--*********************  ТЭП ************************* -->


	<!--*********************  Заявитель ************************* -->
	<xsl:call-template name="param_header">
		<xsl:with-param name="n" select="'Сведения о заявителе'"/>
	</xsl:call-template>
	<w:tbl>
		<w:tblPr>
			<w:tblStyle w:val="PlainTable4" />
			<w:tblW w:w="0" w:type="auto" />
			<w:tblInd w:w="0" w:type="dxa" />
			<w:tblLayout w:type="fixed" />
			<w:tblLook w:val="06A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="4513" />
			<w:gridCol w:w="4513" />
		</w:tblGrid>	
		<xsl:apply-templates select="row/applicant"/>
	</w:tbl>
	<!--*********************  Заявитель ************************* -->
	

	<!--*********************  Сведения об исполнителях работ ************************* -->
	<xsl:call-template name="param_header">
		<xsl:with-param name="n" select="'Сведения об исполнителях работ'"/>
	</xsl:call-template>
	<xsl:apply-templates select="row/contractors"/>	
	<!--*********************  Сведения об исполнителях работ ************************* -->
	
	
	
	<!--*********************  Сведения о застройщике ************************* -->
	<xsl:call-template name="param_header">
		<xsl:with-param name="n" select="'Сведения о застройщике'"/>
	</xsl:call-template>
	<w:tbl>
		<w:tblPr>
			<w:tblStyle w:val="PlainTable4" />
			<w:tblW w:w="0" w:type="auto" />
			<w:tblInd w:w="0" w:type="dxa" />
			<w:tblLayout w:type="fixed" />
			<w:tblLook w:val="06A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="4513" />
			<w:gridCol w:w="4513" />
		</w:tblGrid>	
		<xsl:apply-templates select="row/developer"/>
	</w:tbl>	
	<!--*********************  Сведения о застройщике ************************* -->
	
	<!--*********************  Сведения о техническом заказчике ************************* -->
	<xsl:call-template name="param_header">
		<xsl:with-param name="n" select="'Сведения о техническом заказчике'"/>
	</xsl:call-template>
	<xsl:choose>
	<xsl:when test="row/customer_is_developer='1'">
		<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="4BCC0CBF" w14:textId="6EA77420">
			<w:pPr>
				<w:pStyle w:val="Normal" />
				<w:ind w:left="0" w:firstLine="708" />
				<w:jc w:val="left" />
				<w:rPr>
					<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
					<w:b w:val="1" />
					<w:bCs w:val="1" />
					<w:noProof w:val="0" />
					<w:sz w:val="32" />
					<w:szCs w:val="32" />
					<w:lang w:val="ru-RU" />
				</w:rPr>
			</w:pPr>
			<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
				<w:rPr>
					<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
					<w:b w:val="0" />
					<w:bCs w:val="0" />
					<w:noProof w:val="0" />
					<w:sz w:val="24" />
					<w:szCs w:val="24" />
					<w:lang w:val="ru-RU" />
				</w:rPr>
			</w:r>
		</w:p>
	
		<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="4BCC0CBF" w14:textId="6EA77420">
			<w:pPr>
				<w:pStyle w:val="Normal" />
				<w:ind w:left="0" w:firstLine="708" />
				<w:jc w:val="left" />
				<w:rPr>
					<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
					<w:b w:val="1" />
					<w:bCs w:val="1" />
					<w:noProof w:val="0" />
					<w:sz w:val="32" />
					<w:szCs w:val="32" />
					<w:lang w:val="ru-RU" />
				</w:rPr>
			</w:pPr>
			<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
				<w:rPr>
					<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
					<w:b w:val="0" />
					<w:bCs w:val="0" />
					<w:noProof w:val="0" />
					<w:sz w:val="24" />
					<w:szCs w:val="24" />
					<w:lang w:val="ru-RU" />
				</w:rPr>
				<w:t xml:space="preserve">Технический заказчик является застройщиком.</w:t>
			</w:r>
		</w:p>
	</xsl:when>
	<xsl:otherwise>
	<w:tbl>
		<w:tblPr>
			<w:tblStyle w:val="PlainTable4" />
			<w:tblW w:w="0" w:type="auto" />
			<w:tblInd w:w="0" w:type="dxa" />
			<w:tblLayout w:type="fixed" />
			<w:tblLook w:val="06A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="4513" />
			<w:gridCol w:w="4513" />
		</w:tblGrid>	
		<xsl:apply-templates select="row/customer"/>
	</w:tbl>
	</xsl:otherwise>
	</xsl:choose>
	<!--*********************  Сведения о техническом заказчике ************************* -->


	<!--*********************  Приложения ************************* -->
	<xsl:call-template name="param_header">
		<xsl:with-param name="n" select="'Приложения'"/>
	</xsl:call-template>
	<xsl:apply-templates select="row/documents_pd_eng_survey"/>	
	<!--*********************  Приложения ************************* -->
	

	<!-- CostEvalValidity Files -->
	<xsl:if test="$cost_eval">	
		<xsl:apply-templates select="row/documents_cost_eval_validity"/>
	</xsl:if>
	
	<xsl:call-template name="doc_foot"/>
	
	<w:sectPr>
		<w:pgSz w:w="11906" w:h="16838" w:orient="portrait" />
		<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />
		<w:cols w:space="720" />
		<w:docGrid w:linePitch="360" />
	</w:sectPr>
	
</xsl:template>

<xsl:template name="doc_head">
	<xsl:choose>
	<xsl:when test="row/expertise_type='pd'"><xsl:text>Просим Вас провести государственную экспертизу проектной документации гарантируется.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='eng_survey'"><xsl:text>Просим Вас провести государственную экспертизу результатов инженерных изысканий.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='cost_eval_validity'"><xsl:text>Просим Вас провести государственную экспертизу проверки достоверености сметной стоимости.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='cost_eval_validity_pd'"><xsl:text>Просим Вас провести государственную экспертизу проектной документации и экспертизу проверки достоверености сметной стоимости.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='cost_eval_validity_eng_survey'"><xsl:text>Просим Вас провести государственную экспертизы результатов инженерных изысканий и экспертизу проверки достоверености сметной стоимости.</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='cost_eval_validity_pd_eng_survey'"><xsl:text>Просим Вас провести государственную экспертизы проектной документации, экспертизу результатов инженерных изысканий и экспертизу проверки достоверености сметной стоимости.</xsl:text></xsl:when>
	
	<!--
	<xsl:when test="row/expertise_type='pd' and not(row/exp_cost_eval_validity='t')"><xsl:text>Просим Вас провести государственную экспертизу проектной документации</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='pd' and row/exp_cost_eval_validity='t'"><xsl:text>Просим Вас провести государственную экспертизу проектной документации и проверку достоверености сметной стоимости</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='pd_eng_survey' and not(row/exp_cost_eval_validity='t')"><xsl:text>Просим Вас провести государственную экспертизу проектной документации и результатов инженерных изысканий</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='pd_eng_survey' and row/exp_cost_eval_validity='t'"><xsl:text>Просим Вас провести государственную экспертизу проектной документации, результатов инженерных изысканий, проверку достоверености сметной стоимости</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='eng_survey' and not(row/exp_cost_eval_validity='t')"><xsl:text>Просим Вас провести государственную экспертизу результатов инженерных изысканий</xsl:text></xsl:when>
	<xsl:when test="row/expertise_type='eng_survey' and row/exp_cost_eval_validity='t'"><xsl:text>Просим Вас провести государственную экспертизу результатов инженерных изысканий и проверку достоверености сметной стоимости</xsl:text></xsl:when>
	-->
	<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="doc_foot">
	<xsl:variable name="service">
		<xsl:choose>
		<xsl:when test="row/expertise_type='pd'"><xsl:text>Оплата проведения государственной экспертизы проектной документации гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='eng_survey'"><xsl:text>Оплата проведения государственной экспертизы результатов инженерных изысканий гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='cost_eval_validity'"><xsl:text>Оплата проведения государственной экспертизы проверки достоверености сметной стоимости гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='cost_eval_validity_pd'"><xsl:text>Оплата проведения государственной экспертизы проектной документации и экспертизы проверки достоверености сметной стоимости гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='cost_eval_validity_eng_survey'"><xsl:text>Оплата проведения государственной экспертизы результатов инженерных изысканий и экспертизы проверки достоверености сметной стоимости гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='cost_eval_validity_pd_eng_survey'"><xsl:text>Оплата проведения государственной экспертизы проектной документации, экспертизы результатов инженерных изысканий и экспертизы проверки достоверености сметной стоимости гарантируется.</xsl:text></xsl:when>
		
		<!--
		<xsl:when test="row/expertise_type='pd' and not(row/exp_cost_eval_validity='t')"><xsl:text>Оплата проведения государственной экспертизы проектной документации гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='pd' and row/exp_cost_eval_validity='t'"><xsl:text>Оплата проведения государственной экспертизы проектной документации и проверки достоверености сметной стоимости гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='pd_eng_survey' and not(row/exp_cost_eval_validity='t')"><xsl:text>Оплата проведения государственной экспертизы проектной документации и результатов инженерных изысканий гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='pd_eng_survey' and row/exp_cost_eval_validity='t'"><xsl:text>Оплата проведения государственной экспертизы проектной документации, результатов инженерных изысканий, проверки достоверености сметной стоимости гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='eng_survey' and not(row/exp_cost_eval_validity='t')"><xsl:text>Оплата проведения государственной экспертизы результатов инженерных изысканий гарантируется.</xsl:text></xsl:when>
		<xsl:when test="row/expertise_type='eng_survey' and row/exp_cost_eval_validity='t'"><xsl:text>Оплата проведения государственной экспертизы результатов инженерных изысканий и проверки достоверености сметной стоимости гарантируется.</xsl:text></xsl:when>
		-->
		<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="4BCC0CBF" w14:textId="6EA77420">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="0" w:firstLine="708" />
			<w:jc w:val="left" />
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="32" />
				<w:szCs w:val="32" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="0" />
				<w:bCs w:val="0" />
				<w:noProof w:val="0" />
				<w:sz w:val="24" />
				<w:szCs w:val="24" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:r>
	</w:p>
	
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="4BCC0CBF" w14:textId="6EA77420">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:ind w:left="0" w:firstLine="708" />
			<w:jc w:val="left" />
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="32" />
				<w:szCs w:val="32" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="0" />
				<w:bCs w:val="0" />
				<w:noProof w:val="0" />
				<w:sz w:val="24" />
				<w:szCs w:val="24" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t xml:space="preserve"><xsl:value-of select="$service"/></w:t>
		</w:r>
	</w:p>
</xsl:template>

<xsl:template name="doc_number">
	<xsl:value-of select="row/id"/>
</xsl:template>

<xsl:template name="param_header">
	<xsl:param name="n"/>
	<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="140004BA" w14:textId="68D9C260">
		<w:pPr>
			<w:pStyle w:val="Normal" />
			<w:bidi w:val="0" />
			<w:spacing w:before="0" w:beforeAutospacing="off" w:after="160" w:afterAutospacing="off" w:line="259" w:lineRule="auto" />
			<w:ind w:left="0" w:right="0" />
			<w:jc w:val="left" />
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="24" />
				<w:szCs w:val="24" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
		</w:pPr>
		<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
			<w:rPr>
				<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
				<w:b w:val="1" />
				<w:bCs w:val="1" />
				<w:noProof w:val="0" />
				<w:sz w:val="24" />
				<w:szCs w:val="24" />
				<w:lang w:val="ru-RU" />
			</w:rPr>
			<w:t><xsl:value-of select="$n"/></w:t>
		</w:r>
	</w:p>
</xsl:template>

<xsl:template match="documents_pd_eng_survey">
	<xsl:variable name="str">
		<xsl:choose>
		<xsl:when test="../expertise_type='pd'">Файлы проектной документации:</xsl:when>
		<xsl:when test="../expertise_type='eng_survey'">Файлы результатов инженерных изысканий:</xsl:when>
		<xsl:when test="../expertise_type='pd_eng_survey'">Файлы проектной документации и результатов инженерных изысканий:</xsl:when>
		<xsl:when test="../expertise_type='cost_eval_validity'">Файлы проверки достоверности:</xsl:when>
		<xsl:when test="../expertise_type='cost_eval_validity_pd'">Файлы проектной документации и проверки достоверности:</xsl:when>
		<xsl:when test="../expertise_type='cost_eval_validity_eng_survey'">Файлы результатов инженерных изысканий и проверки достоверности:</xsl:when>
		<xsl:when test="../expertise_type='cost_eval_validity_pd_eng_survey'">Файлы проектной документации, результатов инженерных изысканий, проверки достоверности:</xsl:when>
		<xsl:otherwise></xsl:otherwise>
		</xsl:choose>		
	</xsl:variable>
	<xsl:call-template name="param_header">
		<xsl:with-param name="n" select="$str"/>
	</xsl:call-template>	
	<xsl:apply-templates select="files"/>
</xsl:template>

<xsl:template match="documents_cost_eval_validity">
	<xsl:call-template name="param_header">
		<xsl:with-param name="n" select="'Файлы по проверке достоверености сметной стоимости'"/>
	</xsl:call-template>	
	<xsl:apply-templates select="files"/>
</xsl:template>

<xsl:template match="contractors">
	<w:tbl>
		<w:tblPr>
			<w:tblStyle w:val="PlainTable4" />
			<w:tblW w:w="0" w:type="auto" />
			<w:tblInd w:w="0" w:type="dxa" />
			<w:tblLayout w:type="fixed" />
			<w:tblLook w:val="06A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="4513" />
			<w:gridCol w:w="4513" />
		</w:tblGrid>	
		<xsl:apply-templates select="contractor"/>	
	</w:tbl>
</xsl:template>


<xsl:template match="feature">
	<xsl:variable name="colored">
		<xsl:choose>
		<xsl:when test="(position()+1) mod 2 = 0">1</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:call-template name="show_param">
		<xsl:with-param name="n" select="name"/>
		<xsl:with-param name="v" select="value"/>
		<xsl:with-param name="colored" select="$colored"/>
	</xsl:call-template>

</xsl:template>

<xsl:template match="field">
	<xsl:variable name="colored">
		<xsl:choose>
		<xsl:when test="(position()+1) mod 2 = 0">1</xsl:when>
		<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:call-template name="show_param">
		<xsl:with-param name="n" select="@id"/>
		<xsl:with-param name="v" select="node()"/>
		<xsl:with-param name="colored" select="$colored"/>
	</xsl:call-template>

</xsl:template>

<xsl:template match="files">
	<w:tbl>
		<w:tblPr>
			<w:tblStyle w:val="TableGrid" />
			<w:bidiVisual w:val="0" />
			<w:tblW w:w="0" w:type="auto" />
			<w:tblInd w:w="0" w:type="dxa" />
			<w:tblLayout w:type="fixed" />
			<w:tblLook w:val="06A0" w:firstRow="1" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:noHBand="1" w:noVBand="1" />
		</w:tblPr>
		<w:tblGrid>
			<w:gridCol w:w="6195" />
			<w:gridCol w:w="2831" />
		</w:tblGrid>
		<xsl:apply-templates/>
	</w:tbl>
</xsl:template>

<xsl:template match="file">
	<xsl:variable name="colored">
		<xsl:choose>
		<xsl:when test="position() mod 2 = 0">0</xsl:when>
		<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<w:tr w:rsidR="1F9D1B28" w:rsidTr="1F9D1B28" w14:paraId="07122659">
		<w:tc>
			<w:tcPr>
				<w:tcW w:w="6195" w:type="dxa" />
				<xsl:if test="$colored='1'"><w:shd w:val="clear" w:color="auto" w:fill="D9D9D9" w:themeFill="background1" w:themeFillShade="D9" /></xsl:if>
				<w:tcMar />
			</w:tcPr>
			<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="5E45F970" w14:textId="2440BEEA">
				<w:pPr>
					<w:pStyle w:val="Normal" />
					<w:bidi w:val="0" />
					<w:rPr>
						<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
						<w:b w:val="0" />
						<w:bCs w:val="0" />
						<w:noProof w:val="0" />
						<w:sz w:val="24" />
						<w:szCs w:val="24" />
						<w:lang w:val="ru-RU" />
					</w:rPr>
				</w:pPr>
				<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
					<w:rPr>
						<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
						<w:b w:val="0" />
						<w:bCs w:val="0" />
						<w:noProof w:val="0" />
						<w:sz w:val="24" />
						<w:szCs w:val="24" />
						<w:lang w:val="ru-RU" />
					</w:rPr>
					<w:t><xsl:value-of select="@path"/></w:t>
				</w:r>
			</w:p>
		</w:tc>
		<w:tc>
			<w:tcPr>
				<w:tcW w:w="2831" w:type="dxa" />
				<xsl:if test="$colored='1'"><w:shd w:val="clear" w:color="auto" w:fill="D9D9D9" w:themeFill="background1" w:themeFillShade="D9" /></xsl:if>
				<w:tcMar />
			</w:tcPr>
			<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="5A81AA8C" w14:textId="1883B34B">
				<w:pPr>
					<w:pStyle w:val="Normal" />
					<w:bidi w:val="0" />
					<w:rPr>
						<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
						<w:b w:val="0" />
						<w:bCs w:val="0" />
						<w:noProof w:val="0" />
						<w:sz w:val="24" />
						<w:szCs w:val="24" />
						<w:lang w:val="ru-RU" />
					</w:rPr>
				</w:pPr>
				<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
					<w:rPr>
						<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
						<w:b w:val="0" />
						<w:bCs w:val="0" />
						<w:noProof w:val="0" />
						<w:sz w:val="24" />
						<w:szCs w:val="24" />
						<w:lang w:val="ru-RU" />
					</w:rPr>
					<w:t><xsl:value-of select="@name"/></w:t>
				</w:r>
			</w:p>
		</w:tc>
	</w:tr>
	
</xsl:template>

<xsl:template name="show_param">
	<xsl:param name="n"/>
	<xsl:param name="v"/>
	<xsl:param name="colored"/>
	<w:tr w:rsidR="1F9D1B28" w:rsidTr="1F9D1B28" w14:paraId="12537DF4">
		<w:tc>
			<w:tcPr>
				<w:cnfStyle w:val="001000000000" w:firstRow="0" w:lastRow="0" w:firstColumn="1" w:lastColumn="0" w:oddVBand="0" w:evenVBand="0" w:oddHBand="0" w:evenHBand="0" w:firstRowFirstColumn="0" w:firstRowLastColumn="0" w:lastRowFirstColumn="0" w:lastRowLastColumn="0" />
				<w:tcW w:w="4513" w:type="dxa" />
				<xsl:if test="$colored='1'"><w:shd w:val="clear" w:color="auto" w:fill="D9D9D9" w:themeFill="background1" w:themeFillShade="D9" /></xsl:if>
				<w:tcMar />
			</w:tcPr>
			<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="6992B610" w14:textId="0660C5F6">
				<w:pPr>
					<w:pStyle w:val="Normal" />
					<w:rPr>
						<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
						<w:b w:val="0" />
						<w:bCs w:val="0" />
						<w:noProof w:val="0" />
						<w:sz w:val="24" />
						<w:szCs w:val="24" />
						<w:lang w:val="ru-RU" />
					</w:rPr>
				</w:pPr>
				<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
					<w:rPr>
						<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
						<w:b w:val="0" />
						<w:bCs w:val="0" />
						<w:noProof w:val="0" />
						<w:sz w:val="24" />
						<w:szCs w:val="24" />
						<w:lang w:val="ru-RU" />
					</w:rPr>
					<w:t><xsl:value-of select="$n"/></w:t>
				</w:r>
			</w:p>
		</w:tc>
		<w:tc>
			<w:tcPr>
				<w:cnfStyle w:val="000000000000" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:oddVBand="0" w:evenVBand="0" w:oddHBand="0" w:evenHBand="0" w:firstRowFirstColumn="0" w:firstRowLastColumn="0" w:lastRowFirstColumn="0" w:lastRowLastColumn="0" />
				<w:tcW w:w="4513" w:type="dxa" />
				<xsl:if test="$colored='1'"><w:shd w:val="clear" w:color="auto" w:fill="D9D9D9" w:themeFill="background1" w:themeFillShade="D9" /></xsl:if>
				<w:tcMar />
			</w:tcPr>
			<w:p w:rsidR="1F9D1B28" w:rsidP="1F9D1B28" w:rsidRDefault="1F9D1B28" w14:paraId="37E385B1" w14:textId="5D462E9A">
				<w:pPr>
					<w:pStyle w:val="Normal" />
					<w:rPr>
						<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
						<w:b w:val="0" />
						<w:bCs w:val="0" />
						<w:noProof w:val="0" />
						<w:sz w:val="24" />
						<w:szCs w:val="24" />
						<w:lang w:val="ru-RU" />
					</w:rPr>
				</w:pPr>
				<w:r w:rsidRPr="1F9D1B28" w:rsidR="1F9D1B28">
					<w:rPr>
						<w:rFonts w:ascii="sans-serif" w:hAnsi="sans-serif" w:eastAsia="sans-serif" w:cs="sans-serif" />
						<w:b w:val="0" />
						<w:bCs w:val="0" />
						<w:noProof w:val="0" />
						<w:sz w:val="24" />
						<w:szCs w:val="24" />
						<w:lang w:val="ru-RU" />
					</w:rPr>
					<w:t><xsl:value-of select="$v"/></w:t>
				</w:r>
			</w:p>
		</w:tc>
	</w:tr>
	
</xsl:template>


</xsl:stylesheet>
