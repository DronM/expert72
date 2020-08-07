<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">
 
<xsl:import href="ModelsToHTML.html.xsl"/>

<xsl:template match="/">
	<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>
	<xsl:apply-templates select="document/model[@id='Head_Model']"/>
	<xsl:apply-templates select="document/model[@id='RepReestrExpertise_Model']"/>				
</xsl:template>

<!-- Head -->
<xsl:template match="model[@id='Head_Model']">
	<h3 class="reportTitle">Реестр выданных заключений по государственной экспертизе <xsl:value-of select="row/period_descr"/></h3>
	<div>
	<xsl:choose>
	<xsl:when test="row/expertise_result='positive'">Только положительные заключения</xsl:when>
	<xsl:when test="row/expertise_result='negative'">Только отрицательные заключения</xsl:when>
	<xsl:otherwise test="row/expertise_result='negative'">Все заключения</xsl:otherwise>	
	</xsl:choose>
	</div>
</xsl:template>

</xsl:stylesheet>
