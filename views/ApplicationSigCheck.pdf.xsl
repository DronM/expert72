<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="xml"/> 

<!--
https://www.webucator.com/tutorial/learn-xsl-fo
-->

<!-- Main template -->
<xsl:template match="/">
	<fo:root>
		<fo:layout-master-set>
			<fo:simple-page-master master-name="Report"
				page-height="14.7cm" page-width="21cm" margin-top="0.3cm"
				margin-left="0.2cm" margin-right="0.1cm" margin-bottom="0.3cm">
				<fo:region-body margin-bottom="0.5cm"/>
				<fo:region-before/>
				<fo:region-after extent=".3cm" background-color="silver"/>
			</fo:simple-page-master>
		</fo:layout-master-set>
		<fo:page-sequence master-reference="Report">	  
			<fo:static-content flow-name="xsl-region-after">
				<fo:block font-family="Arial" font-size="6pt" text-align="right">
					Страница <fo:page-number/> из <fo:page-number-citation ref-id="last-page"/>
				</fo:block>
			</fo:static-content>		
			<fo:flow flow-name="xsl-region-body">			
			<xsl:apply-templates select="document/model[@id='Header_Model']"/>		
			<xsl:apply-templates select="document/model[@id='SigCheck_Model']"/>		
			<fo:block id="last-page"/>
			</fo:flow>					
		</fo:page-sequence>
	</fo:root>
</xsl:template>

<xsl:template match="model[@id='Header_Model']">
	<fo:block font-family="Arial" font-style="normal" font-size="12px"
		font-weight="bold" text-align="left">
		Результат проверки ЭЦП по заявлению №<xsl:value-of select="row/application_id"/> от <xsl:value-of select="row/application_date"/>
	</fo:block>

</xsl:template>

<xsl:template match="model[@id='SigCheck_Model']">
	<fo:block-container font-family="Arial" font-style="normal">	
		<fo:table table-layout="fixed">
			<fo:table-column column-width="3%"/>
			<fo:table-column column-width="40%"/>
			<fo:table-column column-width="20%"/>
			<fo:table-column column-width="20%"/>
			<fo:table-column column-width="10%"/>
			<fo:table-column column-width="7%"/>
			
			<fo:table-header text-align="center">
				<fo:table-row font-family="Arial" font-style="normal"
						font-weight="normal" text-align="center" font-size="8pt">
					<fo:table-cell
						display-align="center"
						border-width="0.2mm" border-style="solid">
						<fo:block>№</fo:block>
					</fo:table-cell>					
					<fo:table-cell
						display-align="center"
						border-width="0.2mm" border-style="solid">
						<fo:block>Файл</fo:block>
					</fo:table-cell>					
					<fo:table-cell
						display-align="center"
						border-width="0.2mm" border-style="solid">
						<fo:block>Сертификат владельца ЭЦП</fo:block>
					</fo:table-cell>					
					
					<fo:table-cell
						display-align="center"
						border-width="0.2mm" border-style="solid">
						<fo:block>Сертификат удостоверяющего центра</fo:block>
					</fo:table-cell>					
					<fo:table-cell
						display-align="center"
						border-width="0.2mm" border-style="solid">
						<fo:block>Результат проверки</fo:block>
					</fo:table-cell>					
					<fo:table-cell
						display-align="center"
						border-width="0.2mm" border-style="solid">
						<fo:block>Время,с</fo:block>
					</fo:table-cell>					
					
				</fo:table-row>
			</fo:table-header>
			
			<fo:table-body font-size="6pt">
				<xsl:apply-templates/>						
			</fo:table-body>
		</fo:table>	
	</fo:block-container>		
	<fo:block font-family="Arial" font-style="normal" font-size="7px"
		text-align="left">
		Всего проверено файлов: <xsl:value-of select="count(row)"/>
	</fo:block>
	<fo:block font-family="Arial" font-style="normal" font-size="7px"
		text-align="left">
		Прошло проверку файлов: <xsl:value-of select="count(row/check_result[node()='true'])"/>
	</fo:block>
	<fo:block font-family="Arial" font-style="normal" font-size="7px"
		text-align="left">
		Общее время проверки, секунд: <xsl:value-of select="round( sum(row/check_time) * 10) div 10"/>
	</fo:block>
	
</xsl:template>

<xsl:template match="model/row">
	<xsl:variable name="pos" select="count(preceding-sibling::*)+1"/>

	<xsl:variable name="color">
		<xsl:choose>
		<xsl:when test="check_result='false'">red</xsl:when>
		<xsl:when test="($pos+1) mod 2 = 0">Gainsboro</xsl:when>
		<xsl:otherwise>white</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<fo:table-row height="0.4cm" font-family="Arial" font-style="normal"
				font-weight="normal" text-align="left" background-color="{$color}">
		<fo:table-cell display-align="center" border-width="0.2mm" border-style="solid">>
			<fo:block text-align="center">
				<xsl:value-of select="$pos"/>
			</fo:block>
		</fo:table-cell>																												
		<fo:table-cell display-align="center" border-width="0.2mm" border-style="solid">>
			<fo:block text-align="left">
				<xsl:value-of select="file_name"/>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell border-width="0.2mm" border-style="solid">>
			<fo:block text-align="left">
				<fo:block font-family="Arial" font-style="normal"
					font-weight="normal" text-align="left">
					<xsl:value-of select="concat('Действителен с ',date_from,' по ',date_to)"/>
				</fo:block>
				<xsl:apply-templates select="subject_cert"/>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell border-width="0.2mm" border-style="solid">>
			<fo:block text-align="left">
				<xsl:apply-templates select="issuer_cert"/>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell border-width="0.2mm" border-style="solid">>
			<fo:block>
				<xsl:value-of select="error_str"/>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell display-align="center" border-width="0.2mm" border-style="solid">
			<fo:block text-align="center">
				<xsl:value-of select="check_time"/>
			</fo:block>
		</fo:table-cell>
		
	</fo:table-row>
</xsl:template>

<xsl:template match="field">
	<fo:block font-family="Arial" font-style="normal"
		font-weight="normal" text-align="left">
		<xsl:value-of select="concat(@alias,': ',node())"/>
	</fo:block>
</xsl:template>

</xsl:stylesheet>
