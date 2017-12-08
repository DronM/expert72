<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Captcha'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('common/captcha/Captcha.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct(){
		parent::__construct();<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public static function makeModel(){
		$img = Captcha::getResource();
		$_SESSION['captcha'] = Captcha::getKeystring();
		
		ob_start();
		imagepng($img);
		$buffer = ob_get_contents();
		ob_end_clean();		
		
		return new ModelVars(
			array('name'=>'Vars',
				'id'=>'Captcha_Model',
				'values'=>array(
					new Field('img',DT_STRING,
						array('value'=>base64_encode($buffer))
					)
				)
			)
		);
		
	}
	
	public function get($pm){
		$this->addModel(self::makeModel());
	}
</xsl:template>

</xsl:stylesheet>
