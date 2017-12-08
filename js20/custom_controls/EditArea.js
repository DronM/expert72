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
function EditArea(id,options){
	options = options || {};	
	
	options.tagName = "DIV";
	
	this.m_mainView = options.mainView;
	
	var self = this;
	options.addElement = function(){
		this.addElement(new EditFloat(this.getId()+":val",{
			"length":"19",
			"precision":"4",
			"labelCaption":options.labelCaption,
			"events":{
				"blur":function(){
					self.m_mainView.calcFillPercent();
				}
			}
		}));
		this.addElement(new Enum_aria_units(this.getId()+":unit",{
			"labelCaption":ApplicationDialog_View.prototype.FIELD_CAP_area_unit,
			"events":{
				"change":function(){
					self.m_mainView.calcFillPercent();
				}
			}			
		}));
		
	}
	
	EditArea.superclass.constructor.call(this,id,options);
}
extend(EditArea,EditJSON);

/* Constants */


/* private members */

/* protected*/


/* public methods */
EditArea.prototype.getFillPercent = function(){
	return (
 		( (this.getElement("val").isNull())? 0:70)
		+(this.getElement("unit").isNull()? 0:30)
	);
}
