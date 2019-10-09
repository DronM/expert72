<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml">
 <xsl:output method="xml" indent="yes" />
 <xsl:template match="/">
  <xsl:processing-instruction name="mso-application">
   <xsl:text>progid="Word.Document"</xsl:text>
  </xsl:processing-instruction>
  <w:wordDocument>
   <w:body>
     <xsl:apply-templates select="Courses/Course" />
   </w:body>
  </w:wordDocument>
 </xsl:template>
 <xsl:template match="Course">
    <w:p>
     <w:r>
      <w:t>
       <xsl:value-of select="@Number" />, <xsl:value-of select="Title"/>
      </w:t>
     </w:r>
    </w:p>
 </xsl:template>
</xsl:stylesheet>
