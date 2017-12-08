<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="html.xsl"/>

<!-- -->
<xsl:variable name="TEMPLATE_ID" select="'About'"/>
<!-- -->

<xsl:template match="/">
	<xsl:apply-templates select="metadata/serverTemplates/serverTemplate[@id=$TEMPLATE_ID]"/>
</xsl:template>

<xsl:template match="serverTemplate">
<xsl:comment>
This file is generated from the template build/templates/tmpl/html.xsl
All direct modification will be lost with the next build.
Edit template instead.
</xsl:comment>
<div id="{{{{id}}}}">
	<div class="row">
		<label class="control-label {{{{bsCol}}}}5">
		{{this.LB_APP_NAME}}</label>
		<div>{{this.APP_NAME}}</div>
	</div>
	<div class="row">
		<label class="control-label {{{{bsCol}}}}5">
		{{this.LB_VERSION}}</label>
		<div>{{this.APP_VERSION}}</div>
	</div>

	<div class="row">
		<label class="control-label {{{{bsCol}}}}5">
		{{this.LB_AUTHOR}}</label>
		<div>{{this.APP_AUTHOR}}</div>
	</div>

	<div class="row">
		<label class="control-label {{{{bsCol}}}}5">
		{{this.LB_TECH_MAIL}}</label>
		<div>{{this.TECH_MAIL}}</div>
	</div>
	
	<div class="row">
		<label class="control-label {{{{bsCol}}}}5">
		{{this.LB_DB_NAME}}</label>
		<div>{{this.DB_NAME}}</div>
	</div>
	<div class="row">
		<label class="control-label {{{{bsCol}}}}5">
		{{this.LB_FW_SERVER_VERSION}}</label>
		<div>{{this.FW_VERSION}}</div>
	</div>
	<div class="row">
		<label class="control-label {{{{bsCol}}}}5">
		{{this.LB_FW_CLIENT_VERSION}}</label>
		<div>{{app.VERSION}}</div>
	</div>
</div>
</xsl:template>

</xsl:stylesheet>
