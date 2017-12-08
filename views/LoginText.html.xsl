<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="text"/> 

<!-- Main template-->
<xsl:template match="/">
	<xsl:value-of select="document/model[@id='ModelServResponse']/row[1]/result"/>
</xsl:template>

</xsl:stylesheet>