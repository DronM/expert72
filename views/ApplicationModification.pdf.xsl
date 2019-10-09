<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="Application.docx.xsl"/>

<xsl:template name="doc_head">
	<xsl:text>Просим Вас провести МОДИФИКАЦИЯ </xsl:text>
</xsl:template>

<xsl:template name="doc_foot">
	<fo:block font-family="Arial" font-style="normal"
		margin-top="15px" font-size="8px" text-indent="1cm"
		text-align="left">
		Оплата проведения МОДИФИКАЦИИ гарантируется.
	</fo:block>

</xsl:template>

<xsl:template match="documents_pd">
</xsl:template>

</xsl:stylesheet>
