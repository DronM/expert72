/**	
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_js.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelJSONTree
 
 * @requires core/extend.js
 * @requires core/ModelJSONTree.js
 
 * @param {string} id 
 * @param {Object} options
 */

function ApplicationTemplateContent_Model(options){
	var id = 'ApplicationTemplateContent_Model';
	options = options || {};
	
	options.fields = {};
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = true;	
	
	options.fields.id = new FieldInt("id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.descr = new FieldString("descr",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.required = new FieldBool("required",filed_options);
	
		ApplicationTemplateContent_Model.superclass.constructor.call(this,id,options);
}
extend(ApplicationTemplateContent_Model,ModelJSONTree);


ApplicationTemplateContent_Model.prototype.initSequences = function(){
	for (sid in this.m_sequences){
		this.m_sequences[sid] = (this.m_sequences[sid]==undefined)? 0:this.m_sequences[sid];
		if (!this.m_model[this.getTagRows()]){
			return;
		}
		//console.dir(this.m_model[this.getTagRows()])
		for (var r=0;r < this.m_model[this.getTagRows()].length;r++){
			var row = this.m_model[this.getTagRows()][r];
			for (var c in row.fields){
				if (c==sid){
					var dv = parseInt(row.fields[c],10);
					if (this.m_sequences[sid] < dv){
						this.m_sequences[sid] = dv;
					}
					break;
				}
			}
			//added
			var items = row.items;
			if (items){
				for (var it=0;it < row.items.length;it++){
					if (row.items[it].fields.id){
						var dv = parseInt(row.items[it].fields.id,10);
						if (this.m_sequences[sid] < dv){
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
		
