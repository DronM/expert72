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
	<xsl:apply-templates select="document/model[@id='RepReestrPay_Model']"/>				
</xsl:template>

<!-- Head -->
<xsl:template match="model[@id='Head_Model']">
	<h3>Реестр оплат за период <xsl:value-of select="row/period_descr"/></h3>
	<xsl:if test="not(row/client_name='')">
		<div>Заказчик: <xsl:value-of select="row/client_name"/></div>
	</xsl:if>
	<xsl:if test="not(row/customer_name='') and not(row/customer_name='null')">
		<div>Заявитель: <xsl:value-of select="row/customer_name"/></div>
	</xsl:if>
	
</xsl:template>

<xsl:template match="model[@id='RepReestrPay_Model']">
	<xsl:variable name="model_id" select="@id"/>	
	<table id="{$model_id}" class="tabel table-bordered table-striped">
		<thead>
			<tr>
				<xsl:for-each select="./row[1]/*">
					<xsl:variable name="field_id" select="name()"/>
					<xsl:if test="$field_id != 'sys_level_val' and $field_id != 'sys_level_count' and $field_id != 'sys_level_col_count'">
					<xsl:variable name="label">
						<xsl:choose>
							<xsl:when test="/document/metadata[@modelId=$model_id]/field[@id=$field_id]/@alias">
								<xsl:value-of select="/document/metadata[@modelId=$model_id]/field[@id=$field_id]/@alias"/>
							</xsl:when>
							<xsl:when test="/document/metadata[@modelId=$model_id]/@id">
								<xsl:value-of select="/document/metadata[@modelId=$model_id]/@id"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- <xsl:value-of select="$field_id"/>-->
								<xsl:call-template name="string-replace-all">
									<xsl:with-param name="text" select="$field_id"/>
									<xsl:with-param name="replace" select="'_x0020_'"/>
									<xsl:with-param name="by" select="' '"/>
								</xsl:call-template>																					
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!--<th>&#160;&#160;&#160;&#160;&#160;<xsl:value-of select="$label"/>&#160;&#160;&#160;&#160;&#160;</th>-->
					<th><xsl:value-of select="$label"/></th>
					</xsl:if>
				</xsl:for-each>
			</tr>
		</thead>
	
		<tbody>
			<xsl:apply-templates/>
		</tbody>
		
		<tfoot>
			<tr>
				<td colspan="7">Итого</td>
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
				<td align="right">
					<xsl:call-template name="format_money">
						<xsl:with-param name="val" select="sum(row/pay/node())"/>
					</xsl:call-template>																									
				</td>				
				
				<td colspan="2"></td>
			</tr>
		</tfoot>
	</table>
</xsl:template>

</xsl:stylesheet>
