/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends View
 * @requires core/extend.js
 * @requires controls/View.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ConstrTechnicalFeature_View(id,options){
	options = options || {};	
	
	options.addElement = function(){
		this.addElement(new ConstrTechnicalFeatureGrid(id+":grid"));
		
		if (!options.readOnly){
			var self = this;
			this.addElement(new Control(id+":cmdClose","A",{
				"title":"Удалить данные по объекту",
				"events":{
					"click":function(e){
						WindowQuestion.show({
							"text":"Удалить данные по объекту?",
							"cancel":false,
							"callBack":function(res){			
								if (res==WindowQuestion.RES_YES){
									self.onClosePanel();
								}
							}
						});
					}
				}
			}));
		}
		
	}
	
	ConstrTechnicalFeature_View.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ConstrTechnicalFeature_View,View);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ConstrTechnicalFeature_View.prototype.getModified = function(){
	return this.getElement("grid").getModified();
}
ConstrTechnicalFeature_View.prototype.setValid = function(){
	this.getElement("grid").setValid();
}
ConstrTechnicalFeature_View.prototype.isNull = function(){
	return this.getElement("grid").isNull();
}
ConstrTechnicalFeature_View.prototype.getValueJSON = function(){
	return CommonHelper.unserialize(this.getElement("grid").getValue());
}
ConstrTechnicalFeature_View.prototype.setValue = function(v){
	return this.getElement("grid").setValue(v);
}
