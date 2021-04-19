/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends EditXML
 * @requires core/extend.js
 * @requires controls/EditXML.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Conclusion_tDeclarant(id,options){
	options = options || {};	
	
	options.labelCaption = options.labelCaption || "Сведения о заявителе:";
	options.title = options.title || "Обязательный элемент.";
	
	options.sysNode = false;
	options.controlNameToConclusionTagName = true;
	options.possibleDataTypes = [
		{"dataType":"Organization"
		,"dataTypeDescrLoc":"Организация"
		,"ctrlClass":Conclusion_tOrganization_View
		,"ctrlOptions":{
				"name":"Organization"
			}
		}
		,{"dataType":"ForeignOrganization"
		,"dataTypeDescrLoc":"Иностранная организация"
		,"ctrlClass":Conclusion_tForeignOrganization_View
		,"ctrlOptions":{
				"name":"ForeignOrganization"
			}
		}
		,{"dataType":"IP"
		,"dataTypeDescrLoc":"Индивидуальный предприниматель"
		,"ctrlClass":Conclusion_tIP_View
		,"ctrlOptions":{
				"name":"IP"
			}
		}
		,{"dataType":"Person"
		,"dataTypeDescrLoc":"Физическое лицо"
		,"ctrlClass":Conclusion_tPerson_View
		,"ctrlOptions":{
				"name":"Person"
			}
		}
		
	];
	
	Conclusion_tDeclarant.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tDeclarant,Conclusion_EditCompound);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************

function Conclusion_tDeclarant_View(id,options){

	options.viewClass = Conclusion_tDeclarant;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tObject_View";
	options.headTitle = "Сведения о заявителе:";
	options.dialogWidth = "80%";
	
	Conclusion_tDeclarant_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tDeclarant_View,EditModalDialogXML);

Conclusion_tDeclarant_View.prototype.formatValue = function(val){
	var reg_descr;
	if(val && val.childNodes) {
		var n_list = val.getElementsByTagName("sysValue");
		if(n_list&&n_list.length&&n_list[0].textContent&&n_list[0].textContent.length){
			var reg = CommonHelper.unserialize(n_list[0].textContent);
			reg_descr = reg.getDescr();
		}
	}
	return	(reg_descr? reg_descr:"");
}


