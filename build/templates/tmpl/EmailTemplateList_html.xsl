<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="html.xsl"/>

<!-- -->
<xsl:variable name="TEMPLATE_ID" select="'EmailTemplateList'"/>
<!-- -->

<xsl:template match="/">
	<xsl:apply-templates select="metadata/serverTemplates/serverTemplate[@id=$TEMPLATE_ID]"/>
</xsl:template>

</xsl:stylesheet>
