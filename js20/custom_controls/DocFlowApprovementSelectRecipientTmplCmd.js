/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends GridCmd
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function DocFlowApprovementSelectRecipientTmplCmd(id,options){
	options = options || {};	
	
	options.caption = "Заполнить по шаблону  ";
	options.showCmdControl = true;
	options.glyph = "glyphicon glyphicon-open-file";
	
	this.m_mainView = options.mainView;
	
	DocFlowApprovementSelectRecipientTmplCmd.superclass.constructor.call(this,id,options);
}
extend(DocFlowApprovementSelectRecipientTmplCmd,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
DocFlowApprovementSelectRecipientTmplCmd.prototype.onCommand = function(){
	var self = this;
	var win = (new DocFlowApprovementTemplateList_Form().open());
	win.onSelect = function(fields){
		var pm = (new DocFlowApprovementTemplate_Controller()).getPublicMethod("get_object");
		pm.setFieldValue("id",fields.id.getValue());
		pm.run({
			"ok":function(resp){
				var m = resp.getModel("DocFlowApprovementTemplateDialog_Model");
				if (m.getNextRow()){
					self.m_mainView.getElement("doc_flow_approvement_type").setValue(m.getFieldValue("doc_flow_approvement_type"));
					
					var gr_model = self.getGrid().getModel();
					gr_model.clear();
					gr_model.setData(m.getFieldValue("recipient_list_ref"));
					self.getGrid().onRefresh();
				}
			}
		})		
		win.close();
	}
}

