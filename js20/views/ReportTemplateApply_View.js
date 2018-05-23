/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ReportTemplateApply_View(id,options){
	options = options || {};	
	
	var self = this;
	this.m_paramControls = {};
	options.addElement = function(){
		for (var i=0;i<options.inParams.length;i++){
			var edit_class = eval(options.inParams[i].fields.editCtrlClass);
			var edit_opts = (options.inParams[i].fields.editCtrlOptions)? CommonHelper.unserialize(options.inParams[i].fields.editCtrlOptions) : {};
			var ctrl = new edit_class(id+":param"+i,edit_opts);
			this.addElement(ctrl);
			this.m_paramControls[options.inParams[i].fields.id] = {
				"ctrl":ctrl,
				"form_set":options.inParams[i].fields.form_set,
				"cond":options.inParams[i].fields.cond
			};
		}
	}
	
	ReportTemplateApply_View.superclass.constructor.call(this,id,options);
}
extend(ReportTemplateApply_View,View);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ReportTemplateApply_View.prototype.getParams = function(){
	var res = [];
	for (var id in this.m_paramControls){	
		res.push({
			"id":id,
			"val":this.m_paramControls[id].ctrl.getValue(),
			"cond":(this.m_paramControls[id].cond===true)
		});
	}
	return res;
}
