<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_js20.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Employee'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
	
Employee_Controller.prototype.getInitials = function(fullName){
	var res = "";
	if (fullName &amp;&amp; fullName.length){
		var ar = fullName.split(" ");
		if (ar.length>=1)res = ar[0];
		if (ar.length>=2)res+= " "+(ar[1].substring(0,1)).toUpperCase()+".";
		if (ar.length>=3)res+= " "+(ar[2].substring(0,1)).toUpperCase()+".";
	}
	return res;
}

</xsl:template>

</xsl:stylesheet>
