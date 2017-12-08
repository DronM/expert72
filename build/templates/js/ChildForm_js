<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
/* Copyright (c) 2012 
	Andrey Mikhalevich, Katren ltd.
*/
/*	
	Description
	
	DO NOT MODIFY THIS SCRIPT IN js FILE!!!
	IT IS GENERATED FROM TEMPLATE!!! ChildForm_js.xsl
*/
//ф
/** Requirements
 * @requires controls/ViewList.js
*/

/* constructor */
function ChildForm(options){
	options = options||{};
	options.title=options.title||{};

	<![CDATA[
	var content=
		'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'+
		'<html>'+
		'<head>'+
		'<meta http-equiv="content-type" content="text/html; charset=UTF-8">';
	]]>
		<xsl:apply-templates select="/metadata/cssScripts/cssScript"/>		
	<![CDATA[
		content+=
		'<title>'+options.title+'</title>'+
		'</head>'+			
		'<body>'+		
		'<div id="content"></div>'+
		'<div id="footer"></div>'+
		'<div id="waiting">'+
			'<div>Загрузка библиотек...</div>'+
			'<img src="img/common/wait.gif" alt="загрузка"/>'+
		'</div>';
	]]>
		<xsl:choose>
		<xsl:when test="/metadata/@debug='FALSE'">
		<![CDATA[
		content+='<script src="'+HOST_NAME+'js/lib.js"></script>';
		]]>
		</xsl:when>
		<xsl:otherwise>
		<xsl:apply-templates select="/metadata/jsScripts/jsScript"/>
		</xsl:otherwise>
		</xsl:choose>
	<![CDATA[
		content+='<script>'+
			'var dv = document.getElementById("waiting");'+
			'if (dv!==null){'+
				'dv.parentNode.removeChild(dv);}'+		
		'</script>'+
		
		'</body></html>';
	]]>
	options.location=options.location||"0";
	options.menuBar=options.menuBar||"0";
	options.scrollBars=options.scrollBars||"1";
	options.center=(options.center==undefined)? true:options.center;
	options.status=options.status||"0";
	options.titleBar=options.titleBar||"0";
	options.content=content;	
	ChildForm.superclass.constructor.call(this,options);
}
extend(ChildForm,WindowForm);	

ChildForm.prototype.getContentParent = function(){
	return $("content",this.m_WindowForm.document);
}

</xsl:template>

<xsl:template match="jsScript">
<![CDATA[
content+='<script src="'+HOST_NAME+'js/]]><xsl:value-of select="@file"/><![CDATA[?'+SERV_VARS.VERSION+'"></script>';
]]>
</xsl:template>

<xsl:template match="cssScript">
<![CDATA[
content+='<link rel="stylesheet" href="'+HOST_NAME+'css/]]><xsl:value-of select="@file"/><![CDATA[?'+SERV_VARS.VERSION+'" type="text/css"/>';
]]>
</xsl:template>

</xsl:stylesheet>