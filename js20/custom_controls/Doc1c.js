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
function Doc1c(id,options){
	options = options || {};	
	
	this.m_getContractId = options.getContractId;
	
	var self = this;

	options.addElement = function(){
		this.addElement(new ButtonCmd(id+":makeDoc",{
			"caption":options.caption,
			"onClick":function(e){
				self.makeDoc(e)
			}
		}));
		
		this.addElement(new ControlContainer(id+":docList","TEMPLATE",{
			"elements":options.elements
		}));
	}
	
	options.template = window.getApp().getTemplate("Doc1c");
	
	Doc1c.superclass.constructor.call(this,id,"TEMPLATE",options);
}
extend(Doc1c,ControlContainer);

/* Constants */


/* private members */

/**
 * protected
  * params {ModelXML} model doc_ext_id,doc_number,doc_date
 */
Doc1c.prototype.createDocElement = function(docExtId,docNumber,docDate,docTotal,docType){
	var self = this;
	return new ControlContainer(this.getId()+":docList:cont-"+docExtId,"LI",{
		"elements":[
			new Control(this.getId()+":docList:"+docExtId,"A",{
			"attrs":{
				"href":"#",
				"doc_ext_id":docExtId,
				"doc_number":docNumber,
				"doc_type":docType
			},
			"value":self.getDocDescr(docNumber,docDate,docTotal,docType),
			"events":{
				"click":function(e){
					self.printDoc(this.getAttr("doc_ext_id"),this.getAttr("doc_number"),this.getAttr("doc_type"));
				}
			}
		})
		]
	})
}

/* public methods */
Doc1c.prototype.getPrintWinParams = function(){
	var h = $( window ).width()/3*2;
	var left = $( window ).width()/2;
	var w = left - 20;
	return {
		"top":50,
		"left":left,
		"width":w,
		"height":h
	};
}

