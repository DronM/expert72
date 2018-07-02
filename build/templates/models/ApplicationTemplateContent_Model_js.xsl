<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Model_js.xsl"/>

<!-- -->
<xsl:variable name="MODEL_ID" select="'ApplicationTemplateContent'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
<xsl:template match="/">
	<xsl:apply-templates select="metadata/models/model[@id=$MODEL_ID]"/>
ModelJSON.prototype.initSequences = function(){
	for (sid in this.m_sequences){
		this.m_sequences[sid] = (this.m_sequences[sid]==undefined)? 0:this.m_sequences[sid];
		if (!this.m_model[this.getTagRows()]){
			return;
		}
		//console.dir(this.m_model[this.getTagRows()])
		for (var r=0;r &lt; this.m_model[this.getTagRows()].length;r++){
			var row = this.m_model[this.getTagRows()][r];
			for (var c in row.fields){
				if (c==sid){
					var dv = parseInt(row.fields[c],10);
					if (this.m_sequences[sid] &lt; dv){
						this.m_sequences[sid] = dv;
					}
					break;
				}
			}
			//added
			var items = row.items;
			if (items){
				for (var it=0;it &lt; row.items.length;it++){
					if (row.items[it].fields.id){
						var dv = parseInt(row.items[it].fields.id,10);
						if (this.m_sequences[sid] &lt; dv){
							this.m_sequences[sid] = dv;
						}
					
					}
				}
			}
			//added
		}
		//console.log("Sequence "+sid+"=")
		//console.dir(this.m_sequences[sid])							
	}		
}
		
</xsl:template>
			
</xsl:stylesheet>
