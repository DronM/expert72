<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:import href="Application.pdf.xsl"/>

<xsl:template name="doc_head">
	<xsl:text>Просим Вас провести проверку достоверности определения сметной стоимости объекта капитального строительства </xsl:text>
</xsl:template>

<xsl:template name="doc_foot">
	<fo:block font-family="Arial" font-style="normal"
		margin-top="15px" font-size="8px" text-indent="1cm"
		text-align="left">
		Оплата проведения проверки достоверности определения сметной стоимости объекта капитального строительства гарантируется.
	</fo:block>

</xsl:template>

<xsl:template match="documents_pd">
</xsl:template>

</xsl:stylesheet>
