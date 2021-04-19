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
function Conclusion_tTechnicalCustomer(id,options){
	options = options || {};	
	
	options.sysNode = false;
	options.controlNameToConclusionTagName = true;
	options.possibleDataTypes = [
		{"dataType":"Organization"
		,"dataTypeDescrLoc":"Технический заказчик - Юридическое лицо"
		,"ctrlClass":Conclusion_tOrganization_View
		,"ctrlOptions":{
				"name":"Organization"
			}
		}
		,{"dataType":"ForeignOrganization"
		,"dataTypeDescrLoc":"Технический заказчик - Иностранное юридическое лицо"
		,"ctrlClass":Conclusion_tForeignOrganization_View
		,"ctrlOptions":{
				"name":"ForeignOrganization"
			}
		}
	];
	Conclusion_tTechnicalCustomer.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tTechnicalCustomer,Conclusion_EditCompound);

/* Constants */


/* private members */

/* protected*/


/* public methods */


