<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="html.xsl"/>

<!-- -->
<xsl:variable name="TEMPLATE_ID" select="'ManualForUser'"/>
<!-- -->

<xsl:template match="serverTemplate">
<xsl:comment>
This file is generated from the template build/templates/tmpl/html.xsl
All direct modification will be lost with the next build.
Edit template instead.
</xsl:comment>
<div id="{{{{id}}}}" class="panel panel-flat">
	<div class="panel-heading">
		<h3 class="panel-title">Разделы справки</h3>
	</div>
	<div class="panel-body">
	{{{{#sections}}}}
		<a target="_blank" href="{{{{url}}}}">{{{{descr}}}}
		</a>
	{{{{/sections}}}}
	</div>
</div>
</xsl:template>

</xsl:stylesheet>
