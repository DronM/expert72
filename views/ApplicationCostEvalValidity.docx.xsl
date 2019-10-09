<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:import href="Application.docx.xsl"/>

<xsl:template name="doc_head">
	<xsl:text>Просим Вас провести проверку достоверности определения сметной стоимости объекта капитального строительства </xsl:text>
</xsl:template>

<xsl:template name="doc_foot">
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
			<w:t xml:space="preserve">Оплата проведения проверки достоверности определения сметной стоимости объекта капитального строительства гарантируется.</w:t>
		</w:r>
	</w:p>

</xsl:template>

<xsl:template match="documents_pd">
</xsl:template>

<xsl:template name="doc_number">
	<xsl:choose>
	<xsl:when test="string-length(row/cost_eval_validity_app_id)&gt;0">
		<xsl:value-of select="row/cost_eval_validity_app_id"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="row/id"/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>
