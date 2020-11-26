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
	<h3 class="reportTitle">Квартальный отчет за период <xsl:value-of select="row/period_descr"/></h3>
	<xsl:if test="not(row/service_type_descr='')">
		<div><xsl:value-of select="row/service_type_descr"/></div>
	</xsl:if>

	<xsl:if test="not(row/expertise_type_descr='')">
		<div><xsl:value-of select="row/expertise_type_descr"/></div>
	</xsl:if>
	<xsl:if test="not(row/expertise_result_descr='')">
		<div><xsl:value-of select="row/expertise_result_descr"/></div>
	</xsl:if>
	
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
	
	<xsl:if test="not(row/build_type_name='')">
		<div>Вид строительства: <xsl:value-of select="row/build_type_name"/></div>
	</xsl:if>
	
</xsl:template>

<xsl:template match="model[@id='RepQuarter_Model']">
	<xsl:variable name="model_id" select="@id"/>
	<xsl:variable name="build_type_count" select="count(/document/model[@id='BuildType_Model']/row)"/>		
	
	<table id="{$model_id}" class="tabel table-bordered table-striped">
		<thead>
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
				<td colspan="6">Вид экспертизы</td>
				<td rowspan="2">Вход.см.стоимость</td>
				<td rowspan="2">Вход.реком.см.стоимость</td>
				<td rowspan="2">Тек.см.стоимость</td>
				<td rowspan="2">Тек.реком.см.стоимость</td>
				<td colspan="2">Стоимость эксп.работ</td>
			</tr>
			<tr>
				<xsl:for-each select="/document/model[@id='BuildType_Model']/row">
					<td><xsl:value-of select="name"/></td>
				</xsl:for-each>
				<td>ПД</td>
				<td>РИИ</td>
				<td>ПД и РИИ</td>
				<td>Дост-ть</td>
				<td>ПД и Дост-ть</td>
				<td>ПД, РИИ, Дост-ть</td>
				<td>Бюджет</td>
				<td>Собств.средства</td>
			</tr>
		</thead>
	
		<tbody>
			<xsl:apply-templates/>
		</tbody>
		
		<tfoot>
			<tr>
				<td colspan="{number(9+$build_type_count+6)}">Итого</td>
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
				<td align="right">
					<xsl:call-template name="format_money">
						<xsl:with-param name="val" select="sum(row/expertise_cost_budget/node())"/>
					</xsl:call-template>																									
				</td>				
				<td align="right">
					<xsl:call-template name="format_money">
						<xsl:with-param name="val" select="sum(row/expertise_cost_self_fund/node())"/>
					</xsl:call-template>																									
				</td>				
				
			</tr>
		</tfoot>
	</table>
</xsl:template>

<xsl:template match="row">
	<tr>
		<td><xsl:value-of select="ord"/></td>		
		<td><xsl:value-of select="expertise_result_number"/></td>
		<td align="center">
			<xsl:call-template name="format_date">
				<xsl:with-param name="val" select="date/node()"/>
				<xsl:with-param name="fromatStr" select="''"/>
			</xsl:call-template>																									
		</td>		
		<td><xsl:value-of select="customer"/></td>
		<td><xsl:value-of select="constr_name"/></td>
		<td align="center">
			<xsl:call-template name="format_date">
				<xsl:with-param name="val" select="work_start_date/node()"/>
				<xsl:with-param name="fromatStr" select="''"/>
			</xsl:call-template>																									
		</td>
		<td align="center"><xsl:value-of select="primary_expertise_result_number"/></td>
		<td align="center">
		<xsl:if test="expertise_result='negative'">
			<xsl:call-template name="format_date">
				<xsl:with-param name="val" select="expertise_result_date/node()"/>
				<xsl:with-param name="fromatStr" select="''"/>
			</xsl:call-template>																									
		</xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_result='positive'">
			<xsl:call-template name="format_date">
				<xsl:with-param name="val" select="expertise_result_date/node()"/>
				<xsl:with-param name="fromatStr" select="''"/>
			</xsl:call-template>																									
		</xsl:if>
		</td>
		
		<xsl:variable name="build_type_id" select="build_type_id"/>
		<xsl:for-each select="/document/model[@id='BuildType_Model']/row">
			<td align="center">
			<!-- <i class="glyphicon glyphicon-ok"/>  -->
			<xsl:if test="id=$build_type_id">V</xsl:if>
			</td>
		</xsl:for-each>
		
		<td align="center">
		<xsl:if test="expertise_type='pd'">V</xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_type='eng_survey'">V</xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_type='pd_eng_survey'">V</xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_type='cost_eval_validity' or cost_eval_validity='true'">V</xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_type='cost_eval_validity_pd'">V</xsl:if>
		</td>
		<td align="center">
		<xsl:if test="expertise_type='cost_eval_validity_pd_eng_survey'">V</xsl:if>
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

		<td align="right">
			<xsl:call-template name="format_money">
				<xsl:with-param name="val" select="expertise_cost_budget/node()"/>
			</xsl:call-template>																									
		</td>				
		<td align="right">
			<xsl:call-template name="format_money">
				<xsl:with-param name="val" select="expertise_cost_self_fund/node()"/>
			</xsl:call-template>																									
		</td>				
		
	</tr>
</xsl:template>

</xsl:stylesheet>
