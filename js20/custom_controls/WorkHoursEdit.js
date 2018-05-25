/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditJSON
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function WorkHoursEdit(id,options){
	options = options || {};	
	
	options.tagName = "TEMPLATE";
	
	var self = this;
	options.addElement = function(){
		var bs = window.getBsCol();
		var editContClassName = "input-group "+bs+"9";
		var labelClassName = "control-label "+bs+"3";
	
		for(var i=0;i<this.DAYS.length;i++){
			this.addElement(new EditCheckBox(id+":"+this.DAYS[i],{
				"labelCaption":this.DAYS_ALIAS[i],
				"contClassName":"form-group "+bs+"4",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName,
				"labelAlign":"right"
			}));
			this.addElement(new EditInterval(id+":"+this.DAYS[i]+"_from",{
				"labelCaption":"с",
				"contClassName":"form-group "+bs+"4",
				"editMask":"99:99",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName
			
			}));
			this.addElement(new EditInterval(id+":"+this.DAYS[i]+"_to",{
				"labelCaption":"по",
				"contClassName":"form-group "+bs+"4",
				"editMask":"99:99",
				"editContClassName":editContClassName,
				"labelClassName":labelClassName
			
			}));
		}
	}
	
	WorkHoursEdit.superclass.constructor.call(this,id,options);
}
extend(WorkHoursEdit,EditJSON);

/* Constants */
WorkHoursEdit.prototype.DAYS = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"];
WorkHoursEdit.prototype.DAYS_ALIAS = ["Понедельник","Вторник","Среда","Четверг","Пятница","Суббота","Воскресенье"];

/* private members */

/* protected*/


/* public methods */
WorkHoursEdit.prototype.getValueJSON = function(){	
	
	var o = [];
	for(var i=0;i<this.DAYS.length;i++){
		o.push({
			"checked":this.getElement(this.DAYS[i]).getValue(),
			"from":this.getElement(this.DAYS[i]+"_from").getValue(),
			"to":this.getElement(this.DAYS[i]+"_to").getValue()
		});
	}
	
	return o;
}

WorkHoursEdit.prototype.setValueOrInit = function(v,isInit){
	var o;
	if (typeof(v)=="string"){
		o = CommonHelper.unserialize(v);
	}
	else{
		o = v;
	}
console.dir(o)	
	for(var i=0;i<this.DAYS.length;i++){
		this.getElement(this.DAYS[i]).setValue(o[i].checked);
		this.getElement(this.DAYS[i]+"_from").setValue(o[i].from);
		this.getElement(this.DAYS[i]+"_to").setValue(o[i].to);
	}
	
	
}

