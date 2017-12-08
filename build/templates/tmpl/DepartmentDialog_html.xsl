<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="html.xsl"/>

<!-- -->
<xsl:variable name="TEMPLATE_ID" select="'DepartmentDialog'"/>
<!-- -->

<xsl:template match="/">
	<div id="{{{{id}}}}" class="panel panel-flat">
		<div class="panel-heading">
			<h3 class="panel-title">{{{{HEAD_TITLE}}}}</h3>
		</div>
	
		<div id="{{{{id}}}}:name"/>
	</div>	
</xsl:template>

</xsl:stylesheet>
