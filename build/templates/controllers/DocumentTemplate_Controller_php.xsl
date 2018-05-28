<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'DocumentTemplate'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>
class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	private function add_sections($items,$documentType,$constructionTypeId,$createDate,&amp;$queryStr,&amp;$ind){
		foreach($items as $item){
			if (isset($item->items)){
				$this->add_sections($item->items,$documentType,$constructionTypeId,$createDate,$queryStr,$ind);
			}
			else{
				$queryStr.= ($queryStr=='')? '':',';
				$queryStr.= sprintf("(%s,%d,%s,%d,'%s',%d)",
				$documentType,$constructionTypeId,$createDate,
				intval($item->fields->id),$item->fields->descr,
				$ind
				);
				$ind++;
			}
		}
	
	}
	
	public function insert($pm){
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			$ar = parent::insert($pm);
			$cont = json_decode($pm->getParamValue('content_for_experts'));
			
			$document_type = $this->getExtDbVal($pm,'document_type');
			$construction_type_id = $this->getExtDbVal($pm,'construction_type_id');
			$create_date = $this->getExtDbVal($pm,'create_date');
			
			$queryStr = '';
			$ind = 0;
			$this->add_sections($cont->items,$document_type,$construction_type_id,$create_date,$queryStr,$ind);
			if (strlen($queryStr))
				$this->getDbLinkMaster()->query('INSERT INTO expert_sections
				(document_type,construction_type_id,create_date,section_id,section_name,section_index)
				VALUES '.$queryStr);
				
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
	}	
	public function update($pm){
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$model_name = $this->getUpdateModelId();
			$model = new $model_name($this->getDbLinkMaster());
			$this->methodParamsToModel($pm,$model);
			$q = $model->getUpdateQuery();		
			if (strlen($q)){
				$ar = $this->getDbLink()->query_first($q.' RETURNING document_type,construction_type_id,create_date,content_for_experts');	
				$cont = json_decode($ar['content_for_experts']);
				$ind = 0;
				$this->add_sections(
					$cont->items,
					"'".$ar['document_type']."'",
					$ar['construction_type_id'],
					"'".$ar['create_date']."'",
					$queryStr,
					$ind
				);
				if (strlen($queryStr))
					$this->getDbLinkMaster()->query('INSERT INTO expert_sections
					(document_type,construction_type_id,create_date,section_id,section_name,section_index)
					VALUES '.$queryStr);
				
			}
			
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw $e;
		}
	}	

</xsl:template>

</xsl:stylesheet>
