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
	<h3>Реестр выданных заключений по государственной экспертизе <xsl:value-of select="row/period_descr"/></h3>
</xsl:template>


<!-- table -->
<xsl:template match="model[@id='Reestr_Model']">
	<table id="RepReestrExpertise" class="table table-bordered table-striped">
		<!-- header -->
		<thead>
		<tr>
			<th>№</th>
			<th>Исполнитель работ</th>
			<th>Государственные эксперты</th>
			<th>Договор на проведение гос.экспертизы</th>
			<th>Объект строительства</th>
			<th>Адрес объекта</th>
			<th>Технико-экономические характеристики</th>
			<th>Кадастровый номер з/у</th>
			<th>№ ГПЗУ</th>
			<th>Застройщик/Технический заказчик</th>
			<th>Правоустанавливающие документы на з/у</th>
			<th>Результат экспертизы (отриц.с описанием)</th>
			<th>Вид экспертизы</th>
			<th>№ экспертного заключения</th>
			<th>Дата заключения</th>
			<th>Дата предоставления документов</th>
			<th>Дата внесения платы</th>
			<th>Дата вручения заключения</th>
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
		<td><xsl:value-of select="contrcator_names"/></td>
		<td><xsl:value-of select="experts"/></td>
		<td><xsl:value-of select="contract_number"/> от <xsl:value-of select="contract_date_descr"/></td>
		<td><xsl:value-of select="constr_name"/></td>
		<td><xsl:value-of select="constr_address"/></td>
		<td><xsl:value-of select="constr_features"/></td>
		<td><xsl:value-of select="kadastr_number"/></td>
		<td><xsl:value-of select="grad_plan_number"/></td>
		<td><xsl:if test="developer_name!=''"><xsl:value-of select="developer_name"/></xsl:if><xsl:if test="customer_name!=developer_name"><xsl:if test="developer_name!=''">, </xsl:if><xsl:value-of select="customer_name"/></xsl:if></td>
		<td><xsl:value-of select="area_document"/></td>
		<td>
			<xsl:choose>
			<xsl:when test="expertise_result='negative'">Отрицательое заключение: <xsl:value-of select="reject_type_descr"/></xsl:when>
			<xsl:when test="expertise_result='positive'">Положительное заключение</xsl:when>
			<xsl:otherwise>Заключение не выдано</xsl:otherwise>
			</xsl:choose>
		</td>
		<td>
			<xsl:choose>
			<xsl:when test="expertise_type='pd'">ПД</xsl:when>
			<xsl:when test="expertise_type='eng_survey'">РИИ</xsl:when>
			<xsl:when test="expertise_type='pd_eng_survey'">ПД и РИИ</xsl:when>
			<xsl:otherwise>-</xsl:otherwise>
			</xsl:choose>
		</td>
		
		<td><xsl:value-of select="reg_number"/></td>
		<td><xsl:value-of select="expertise_result_date_descr"/></td>
		<td><xsl:value-of select="date_time_descr"/></td>
		<td><xsl:value-of select="pay_date_descr"/></td>
		<td><xsl:value-of select="expertise_result_ret_date_descr"/></td>
	</tr>
</xsl:template>

</xsl:stylesheet>
