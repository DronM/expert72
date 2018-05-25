/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditModalDialog
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function EditRespPerson(id,options){
	options = options || {};	

	options.viewClass = ViewRespPerson;
	options.viewTemplate = "EditRespPerson";
	options.headTitle = "Редактирование данных физического лица";
	
	this.m_minInf = options.minInf;
	this.m_mainView = options.mainView;		
			
	EditRespPerson.superclass.constructor.call(this,id,options);
}
extend(EditRespPerson,EditModalDialog);

/* Constants */


/* private members */

/* protected*/


/* public methods */
EditRespPerson.prototype.formatValue = function(val){
	var res = "";
	for (var id in val){
		if (id=="tel" && val[id]){
			var input = new Control(this.getId()+":mask","input",{"attrs":{"value":val[id]},"visible":false});
			$(input.getNode()).mask(window.getApp().getPhoneEditMask());
			res+= ((res=="")? "":", ") + input.getNode().value;
			
		}
		else if (val[id] && typeof(val[id])=="object" && val[id].isNull()){
			res+= ((res=="")? "":", ") + val[id].getDescr();
		}
		else if (val[id] && val[id]!=""){
			res+= ((res=="")? "":", ") + val[id];
		}
		
	}
	return res;	
}
EditRespPerson.prototype.getFillPercent = function(){
	return (
		this.m_minInf? 100 :
		(
			((this.m_valueJSON && this.m_valueJSON["name"])? 34:0)
			+((this.m_valueJSON && this.m_valueJSON.post)? 33:0)
			+((this.m_valueJSON && this.m_valueJSON.tel)? 33:0)
		)
	);
}

EditRespPerson.prototype.closeSelect = function(){
	this.m_mainView.calcFillPercent();
	
	EditRespPerson.superclass.closeSelect.call(this);
}
