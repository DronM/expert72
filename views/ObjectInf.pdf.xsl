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
				page-height="21cm" page-width="14.7cm" margin-top="0.5cm"
				margin-left="1cm" margin-right="0.5cm" margin-bottom="0.5cm">
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
			<xsl:apply-templates select="document/model"/>		
			<fo:block id="last-page"/>
			</fo:flow>					
		</fo:page-sequence>
	</fo:root>
</xsl:template>

<xsl:template match="model[@id='ObjectData_Model']">
	<fo:block text-align="center">
		<fo:external-graphic
			src="url('img/TyumReg.jpeg')"
			width="30%"
			content-height="30%"
    			content-width="scale-to-fit"
    			scaling="uniform"/>
	</fo:block>

	<fo:block font-family="Arial" font-style="normal" font-size="12px" text-align="center">
		<fo:block>Российская Федерация</fo:block>
		<fo:block>Тюменская область</fo:block>
	</fo:block>

	<fo:block margin-top="10px" font-family="Arial" font-style="normal" font-size="12px" font-weight="bold" text-align="center">
		<fo:block>Государственное автономное учреждение</fo:block>
		<fo:block>Тюменской области</fo:block>
		<fo:block>"Управление государственной экспертизы</fo:block>
		<fo:block>проектной документации"</fo:block>
	</fo:block>

	<fo:table table-layout="fixed" margin-top="10px">
		<fo:table-column column-width="50%"/>
		<fo:table-column column-width="50%"/>
		
		<fo:table-body font-family="Arial" font-size="8px">
			<fo:table-row>
				<fo:table-cell>
					<fo:block text-align="left">625000, г. Тюмень, ул. Максима Горького, 76</fo:block>
				</fo:table-cell>																												
				<fo:table-cell>
					<fo:block text-align="right">
						<fo:block>тел. (3452) 56-54-90, факс 56-54-80</fo:block>
						<fo:block>TymGosExpert@mail.ru</fo:block>
						<fo:block>www.expertiza72.ru</fo:block>		
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
		</fo:table-body>
	</fo:table>

	<fo:block font-family="Arial" font-size="8px" text-align="left">Исх. № _______         от "____"  ____________ 20__ года</fo:block>

	<fo:block margin-top="10px" font-family="Arial" font-style="normal" font-size="10px" text-align="center">
		<fo:block>ВЫПИСКА</fo:block>
		<fo:block>из Реестра выданных заключений государственной экспертизы проектной</fo:block>
		<fo:block>документации и результатов инженерных изысканий</fo:block>
	</fo:block>

	<fo:table table-layout="fixed" margin-top="20px">
		<fo:table-column column-width="50%"/>
		<fo:table-column column-width="50%"/>
		
		<fo:table-body font-family="Arial" font-size="8px">
			<fo:table-row>
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">Наименование объекта капитального строительства</fo:block>
				</fo:table-cell>																												
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left"><xsl:value-of select="row/constr_name"/>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
			
			<fo:table-row>
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">Почтовый (строительный) адрес объекта капитального строительства (номер градостроительного плана/кадастровый номер земельного участка/документы на земельный участок)</fo:block>
				</fo:table-cell>																												
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left"><xsl:value-of select="row/constr_address"/>
						<xsl:if test="row/grad_plan_number">, <xsl:value-of select="row/grad_plan_number"/></xsl:if>
						<xsl:if test="row/kadastr_number">, <xsl:value-of select="row/kadastr_number"/></xsl:if>
						<xsl:if test="row/area_document">, <xsl:value-of select="row/area_document"/></xsl:if>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
			
			<fo:table-row>
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">Заказчик</fo:block>
				</fo:table-cell>																												
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left"><xsl:value-of select="row/customer_name"/>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>

			<fo:table-row>
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">Исполнитель работ по подготовке документации</fo:block>
				</fo:table-cell>																												
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left"><xsl:value-of select="row/contrcator_names"/>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>

			<fo:table-row>
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">Материалы, в отношении которых выдано заключение государственной экспертизы</fo:block>
				</fo:table-cell>																												
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">
						<xsl:choose>
						<xsl:when test="row/document_type='pd'">ПД</xsl:when>
						<xsl:when test="row/document_type='eng_survey'">РИИ</xsl:when>
						<xsl:when test="row/document_type='pd_eng_survey'">ПД и РИИ</xsl:when>
						<xsl:when test="row/document_type='cost_eval_validity'">Достоверность</xsl:when>
						<xsl:otherwise>Заключение не выдано</xsl:otherwise>
						</xsl:choose>
					
					</fo:block>
				</fo:table-cell>
			</fo:table-row>

			<fo:table-row>
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">Результат заключения государственной экспертизы</fo:block>
				</fo:table-cell>																												
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">
						<xsl:choose>
						<xsl:when test="row/expertise_result='positive'">Положительное заключение</xsl:when>
						<xsl:when test="row/expertise_result='negative'">Отрицательное заключение</xsl:when>
						<xsl:otherwise>Заключение не выдано</xsl:otherwise>
						</xsl:choose>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
			
			<fo:table-row>
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">Дата выдачи</fo:block>
				</fo:table-cell>																												
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left"><xsl:value-of select="row/expertise_result_date_descr"/>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>

			<fo:table-row>
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left">Регистрационный номер</fo:block>
				</fo:table-cell>																												
				<fo:table-cell border-width="0.2mm" border-style="solid">
					<fo:block text-align="left"><xsl:value-of select="row/reg_number"/>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
			
			<xsl:for-each select="/document/model[@id='FeatureList_Model']/row">	
				<fo:table-row>
					<fo:table-cell border-width="0.2mm" border-style="solid">
						<fo:block text-align="left"><xsl:value-of select="n"/></fo:block>
					</fo:table-cell>																												
					<fo:table-cell border-width="0.2mm" border-style="solid">
						<fo:block text-align="left"><xsl:value-of select="v"/></fo:block>
					</fo:table-cell>
				</fo:table-row>
			</xsl:for-each>
		</fo:table-body>
	</fo:table>
	
	<fo:table table-layout="fixed" margin-top="50px">
		<fo:table-column column-width="50%"/>
		<fo:table-column column-width="50%"/>
		
		<fo:table-body font-family="Arial" font-size="8px">
			<fo:table-row>
				<fo:table-cell>
					<fo:block text-align="right">Директор</fo:block>
				</fo:table-cell>																												
				<fo:table-cell>
					<fo:block text-align="right">
						<fo:block>________________________ А. А. Кучерявый</fo:block>
					</fo:block>
				</fo:table-cell>
			</fo:table-row>
		</fo:table-body>
	</fo:table>

</xsl:template>


<xsl:template match="model[@id='FeatureList_Model']/row">
</xsl:template>

</xsl:stylesheet>
