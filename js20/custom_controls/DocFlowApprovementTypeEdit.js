/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {Control} options.view
 */
function DocFlowApprovementTypeEdit(id,options){
	options = options || {};	
	
	this.m_mainView = options.view;

	var bs = window.getBsCol();
	var editContClassName = "input-group "+bs+"10";
	var labelClassName = "control-label "+bs+"2";
	
	options.editContClassName = "input-group "+bs+"9";
	options.labelClassName = "control-label "+bs+"3";			
	options.required = true;
	options.labelCaption = "Направлять на согласование:";
	
	var self = this;
	
	options.elements = [
		new EditRadio(id+":doc_flow_approvement_type:to_all",{
			"name":"doc_flow_approvement_type",
			"value":"to_all",
			"labelCaption":"Всем",
			"contClassName":window.getBsCol(4),
			"labelClassName":"control-label "+window.getBsCol(6),
			"checked":true,
			"events":{
				"change":function(){
					self.changeType();
				}
			}
		})
		,new EditRadio(id+":doc_flow_approvement_type:to_one",{
			"name":"doc_flow_approvement_type",
			"value":"to_one",
			"labelCaption":"По очереди",
			"contClassName":window.getBsCol(4),
			"labelClassName":"control-label "+window.getBsCol(6),
			"checked":true,
			"events":{
				"change":function(){
					self.changeType();
				}
			}
		})
		,new EditRadio(id+":doc_flow_approvement_type:mixed",{
			"name":"doc_flow_approvement_type",
			"value":"mixed",
			"labelCaption":"Смешанно",
			"contClassName":window.getBsCol(4),
			"labelClassName":"control-label "+window.getBsCol(6),
			"checked":true,
			"events":{
				"change":function(){
					self.changeType();
				}
			}
		})

	];
	
	DocFlowApprovementTypeEdit.superclass.constructor.call(this,id,options);
}
extend(DocFlowApprovementTypeEdit,EditRadioGroup);

/* Constants */


/* private members */
DocFlowApprovementTypeEdit.prototype.m_mainView;
/* protected*/


/* public methods */
DocFlowApprovementTypeEdit.prototype.changeType = function(){
	var ord_vis = (this.getValue()=="mixed")? true:false;
	this.m_mainView.getElement("recipient_list_ref").setColumnVisible("approvement_order",ord_vis);
	this.m_mainView.getElement("recipient_list_ref").calcSteps();
}
