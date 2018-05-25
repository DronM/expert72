/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends EditJSON
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function WorkHourEdit(id,options){
	options = options || {};	
	
	options.tagName = "DIV";
	
	var self = this;
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"9";
		var labelClassName = "control-label "+bs+"3";
	
		this.addElement(new EditInterval(id+":from",{
			"labelCaption":"с",
			"contClassName":"form-group "+bs+"4",
			"editMask":"99:99",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName
		
		}));
		this.addElement(new EditInterval(id+":to",{
			"labelCaption":"по",
			"contClassName":"form-group "+bs+"4",
			"editMask":"99:99",
			"editContClassName":editContClassName,
			"labelClassName":labelClassName
		
		}));
	}
	
	WorkHourEdit.superclass.constructor.call(this,id,options);
}
extend(WorkHourEdit,EditJSON);

/* Constants */


/* private members */

/* protected*/


/* public methods */

