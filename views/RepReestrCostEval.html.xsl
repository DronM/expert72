<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">
 
<xsl:import href="functions.xsl"/>

<!-- Main template-->
<xsl:template match="/">
	<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>	
	<xsl:apply-templates select="document/model[@id='Head_Model']"/>	
	<xsl:apply-templates select="document/model[@id='Reestr_Model']"/>		
</xsl:template>

<!-- Error -->
<xsl:template match="model[@id='ModelServResponse']">
	<xsl:if test="not(row[1]/result='0')">
	<div class="error">
		<xsl:value-of select="row[1]/descr"/>
	</div>
	</xsl:if>
</xsl:template>

<!-- Head -->
<xsl:template match="model[@id='Head_Model']">
	<h3>Реестр выданных заключений по достоверности <xsl:value-of select="row/period_descr"/></h3>
</xsl:template>


<!-- table -->
<xsl:template match="model[@id='Reestr_Model']">
	<table id="RepReestrCostEval" class="table table-bordered table-striped">
		<!-- header -->
		<thead>
		<tr>
			<th>№</th>
			<th>Объект строительства</th>
			<th>Адрес объекта/ТЭП</th>
			<th>Заказчик/Застройщик</th>
			<th>Проектная организация</th>
			<th>Сведения о результате заключения</th>
			<th>№ и дата заключения</th>
			<th>Сведения о решении по объекту</th>
			<th>Сведения об оспаривании</th>
		</tr>
		</thead> 		 
		<tbody>
			<xsl:apply-templates select="row"/>		
		</tbody>
		
	</table>
</xsl:template>

<xsl:template match="model[@id='Reestr_Model']/row">
	<tr>
		<td><xsl:value-of select="position()"/></td>
		<td><xsl:value-of select="constr_name"/></td>
		<td><xsl:value-of select="constr_address"/><xsl:if test="constr_address!=''">, </xsl:if><xsl:value-of select="constr_features"/></td>
		<td><xsl:if test="customer_name!=''"><xsl:value-of select="customer_name"/></xsl:if><xsl:if test="customer_name!=developer_name"><xsl:if test="customer_name!=''">, </xsl:if><xsl:value-of select="developer_name"/></xsl:if></td>
		<td><xsl:value-of select="contrcator_names"/></td>
		<td>
			<xsl:choose>
			<xsl:when test="expertise_result='negative'">Отрицательое заключение: <xsl:value-of select="reject_type_descr"/></xsl:when>
			<xsl:when test="expertise_result='positive'">Положительное заключение</xsl:when>
			<xsl:otherwise>Заключение не выдано</xsl:otherwise>
			</xsl:choose>
		</td>
		<td><xsl:value-of select="reg_number"/> от <xsl:value-of select="expertise_result_date_descr"/></td>
		<td></td>		
		<td><xsl:value-of select="argument_document"/></td>
	</tr>
</xsl:template>

</xsl:stylesheet>
