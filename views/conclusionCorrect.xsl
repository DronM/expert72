<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

<!--	Формирование файла XML заключения
	Copies all nodes applying these rules:
	1) Attribute skeepNode='TRUE' - skeep node and all thildren
	2) Attribute sysNode='TRUE' - skeep node copy children
	3) if Attribute conclusionTagName exists put its value as NodeName
-->
<xsl:template match="@* | node()">
	<xsl:choose>
	<xsl:when test="@skeepNode='TRUE'">
		<!-- Skeep node and all thildren -->
	</xsl:when>
	<xsl:when test="@sysNode='TRUE'">
		<!-- Skeep this node, copy children -->
		<xsl:apply-templates select="node()"/>
	</xsl:when>
	<xsl:when test="@conclusionTagName">
		<!-- Change node tag to @conclusionTagName --> 
		<xsl:element name="{@conclusionTagName}">
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:when>
	<xsl:otherwise>
		<!-- Copy as is --> 
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>
    
</xsl:stylesheet>
