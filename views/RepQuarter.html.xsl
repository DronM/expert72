<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">
 
<xsl:import href="ModelsToHTML.html.xsl"/>
<xsl:import href="functions.xsl"/>

<xsl:template match="/">
	<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>
	<xsl:apply-templates select="document/model[@id='Head_Model']"/>
	<xsl:apply-templates select="document/model[@id='RepQuarter_Model']"/>				
</xsl:template>

<!-- Head -->
<xsl:template match="model[@id='Head_Model']">
	<h3>Квартальный отчет за период <xsl:value-of select="row/period_descr"/></h3>
	
	<xsl:if test="not(row/client_name='')">
		<div>Заказчик: <xsl:value-of select="row/client_name"/></div>
	</xsl:if>
	<xsl:if test="not(row/customer_name='') and not(row/customer_name='null')">
		<div>Заявитель: <xsl:value-of select="row/customer_name"/></div>
	</xsl:if>
	<xsl:if test="not(row/contractor_name='') and not(row/contractor_name='null')">
		<div>Исполнитель: <xsl:value-of select="row/contractor_name"/></div>
	</xsl:if>
	<xsl:if test="not(row/main_expert_name='') and not(row/main_expert_name='null')">
		<div>Главный эксперт: <xsl:value-of select="row/main_expert_name"/></div>
	</xsl:if>
	<xsl:if test="not(row/constr_name='') and not(row/constr_name='null')">
		<div>Объект: <xsl:value-of select="row/constr_name"/></div>
	</xsl:if>
	
	<xsl:if test="not(row/expertise_type_descr='')">
		<div><xsl:value-of select="row/expertise_type_descr"/></div>
	</xsl:if>
	<xsl:if test="not(row/expertise_result_descr='')">
		<div><xsl:value-of select="row/expertise_result_descr"/></div>
	</xsl:if>
	<xsl:if test="not(row/build_type_name='')">
		<div>Вид строительства: <xsl:value-of select="row/build_type_name"/></div>
	</xsl:if>
	
</xsl:template>

<xsl:template match="model[@id='RepQuarter_Model']">
	<xsl:variable name="model_id" select="@id"/>
	<xsl:variable name="build_type_count" select="count(/document/model[@id='BuildType_Model']/row)"/>		
	
	<table id="{$model_id}" class="tabel table-bordered table-striped">
		<thead>
			<field id="ord" dataType="String" alias="" />
			<field id="expertise_result_number" dataType="String" alias="" />
			<field id="date" dataType="Date" alias="" />
			<field id="customer" dataType="String" alias="" />
			<field id="constr_name" dataType="String" alias="" />
			<field id="work_start_date" dataType="Date" alias="" />			
			<field id="primary_expertise_result_number" dataType="String" alias="" />
			<field id="expertise_result" dataType="String" alias="Результат" />
			<field id="expertise_result_date" dataType="Date" alias="Дата выдачи результата" />
			<field id="build_type_id" dataType="Int" alias="Вид строительства код" />
			<field id="build_type_name" dataType="String" alias="Вид строительства наименование" />
			<field id="expertise_type" dataType="String" alias="Вид экспертизы" />
			<field id="in_estim_cost" dataType="Float" alias="Вход.сметная стоим." />
			<field id="in_estim_cost_recommend" alias="Вход.сметная рекоменд.стоим." />
			<field id="cur_estim_cost" dataType="Float" alias="Текущая сметн.стоим." />
			<field id="cur_estim_cost_recommend" dataType="Float" alias="Текущая рекоменд.сметн.стоим." />
		
			<tr align="center">
				<td rowspan="2">№</td>
				<td rowspan="2">№ эксп.заключ.</td>
				<td rowspan="2">Дата пост.</td>
				<td rowspan="2">Заказчик</td>
				<td rowspan="2">Объект строительства</td>
				<td rowspan="2">Дата нач.работ</td>
				<td rowspan="2">Номер первичного заключ.</td>
				<td rowspan="2">Дата отриц.зак.</td>
				<td rowspan="2">Дата положит.зак.</td>
				<td colspan="{$build_type_count}">Вид строительства</td>
				<td colspan="3">Вид экспертизы</td>
				<td rowspan="2">Вход.см.стоимость</td>
				<td rowspan="2">Вход.реком.см.стоимость</td>
				<td rowspan="2">Тек.см.стоимость</td>
				<td rowspan="2">Тек.реком.см.стоимость</td>
				
			</tr>
			<tr>
				<xsl:for-each select="/document/model[@id='BuildType_Model']/row">
					<td><xsl:value-of select="name"/></td>
				</xsl:for-each>
				<td>ПД</td>
				<td>РИИ</td>
				<td>ПД и РИИ</td>
			</tr>
		</thead>
	
		<tbody>
			<xsl:apply-templates/>
		</tbody>
		
		<tfoot>
			<tr>
				<td colspan="{number(9+$build_type_count+3)}">Итого</td>
				<td align="right">
					<xsl:call-template name="format_money">
						<xsl:with-param name="val" select="sum(row/in_estim_cost/node())"/>
					</xsl:call-template>																									
				</td>				
				<td align="right">
					<xsl:call-template name="format_money">
						<xsl:with-param name="val" select="sum(row/in_estim_cost_recommend/node())"/>
					</xsl:call-template>																									
				</td>				
				<td align="right">
					<xsl:call-template name="format_money">
						<xsl:with-param name="val" select="sum(row/cur_estim_cost/node())"/>
					</xsl:call-template>																									
				</td>				
				<td align="right">
					<xsl:call-template name="format_money">
						<xsl:with-param name="val" select="sum(row/cur_estim_cost_recommend/node())"/>
					</xsl:call-template>																									
				</td>				
				
			</tr>
		</tfoot>
	</table>
</xsl:template>

<xsl:template match="row">
	<tr>
			<field id="" dataType="String" alias="№ эксп.заключ." />
			<field id="date" dataType="Date" alias="Дата пост." />
			<field id="" dataType="String" alias="Заказчик" />
			<field id="" dataType="String" alias="Объект строительства" />
			<field id="" dataType="Date" alias="Дата нач.работ" />			
			<field id="expertise_result" dataType="String" alias="Результат" />
			<field id="expertise_result_date" dataType="Date" alias="Дата выдачи результата" />
			<field id="build_type_id" dataType="Int" alias="Вид строительства код" />
			<field id="build_type_name" dataType="String" alias="Вид строительства наименование" />
			<field id="expertise_type" dataType="String" alias="Вид экспертизы" />
			<field id="in_estim_cost" dataType="Float" alias="Вход.сметная стоим." />
			<field id="in_estim_cost_recommend" alias="Вход.сметная рекоменд.стоим." />
			<field id="cur_estim_cost" dataType="Float" alias="Текущая сметн.стоим." />
			<field id="cur_estim_cost_recommend" dataType="Float" alias="Текущая рекоменд.сметн.стоим." />
	
		<td><xsl:value-of select="ord"/></td>
		<td><xsl:value-of select="date"/></td>
		<td><xsl:value-of select="expertise_result_number"/></td>
		<td><xsl:value-of select="customer"/></td>
		<td><xsl:value-of select="constr_name"/></td>
		<td align="center"><xsl:value-of select="work_start_date"/></td>
		<td align="center"><xsl:value-of select="primary_expertise_result_number"/></td>
		<td align="center">
		<xsl:if test="expertise_result='negative'"><xsl:value-of select="expertise_result_date"/></xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_result='positive'"><xsl:value-of select="expertise_result_date"/></xsl:if>
		</td>
		
		<xsl:variable name="build_type_id" select="build_type_id"/>
		<xsl:for-each select="/document/model[@id='BuildType_Model']/row">
			<td align="center">
			<xsl:if test="id=$build_type_id"><i class="glyphicon glyphicon-ok"/> </xsl:if>
			</td>
		</xsl:for-each>
		
		<td align="center">
		<xsl:if test="expertise_type='pd'"><i class="glyphicon glyphicon-ok"/> </xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_type='eng_survey'"><i class="glyphicon glyphicon-ok"/> </xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_type='pd_eng_survey'"><i class="glyphicon glyphicon-ok"/> </xsl:if>
		</td>
		
		<td align="right">
			<xsl:call-template name="format_money">
				<xsl:with-param name="val" select="in_estim_cost/node()"/>
			</xsl:call-template>																									
		</td>				
		<td align="right">
			<xsl:call-template name="format_money">
				<xsl:with-param name="val" select="in_estim_cost_recommend/node()"/>
			</xsl:call-template>																									
		</td>				
		<td align="right">
			<xsl:call-template name="format_money">
				<xsl:with-param name="val" select="cur_estim_cost/node()"/>
			</xsl:call-template>																									
		</td>				
		<td align="right">
			<xsl:call-template name="format_money">
				<xsl:with-param name="val" select="cur_estim_cost_recommend/node()"/>
			</xsl:call-template>																									
		</td>				
		
	</tr>
</xsl:template>

</xsl:stylesheet>