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
function Akt1c(id,options){
	options = options || {};	
	
	options.addElement = function(){
		this.addElement(new ButtonCmd(id+":makeAkt",{
			"caption":"Создать акт",
			"onClick":function(){
				self.makeAkt();
			},
			"enabled":(options.akt1c_id==undefined)
		}));
				
		this.addElement(new Control(id+":akt","TEMPLATE",{
			"attrs":{
				"id1c":options.akt1c_id
			},
			"value":options.akt1c_descr,
			"events":{
				"click":function(){
					self.downloadAkt(this.getAttr("id1c"));
				}
			}
		}));
	
	}
	
	Akt1c.superclass.constructor.call(this,id,"TEMPLATE",options);
}
extend(Akt1c,ControlContainer);

/* Constants */


/* private members */

/* protected*/


/* public methods */

Akt1c.prototype.downloadAkt = function(id1c){
	alert("downloadAkt "+id1c)
}
Akt1c.prototype.makeAkt = function(){
	alert("makeAkt")
}
