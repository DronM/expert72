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
function Conclusion_tConclusionNumber(id,options){
	options = options || {};	
	
	options.sysNode = true;
	options.controlNameToConclusionTagName = true;
	
	options.possibleDataTypes = [
		{"dataType":"EGRZ"
		,"dataTypeDescrLoc":"Номер заключения экспертизы в формате ЕГРЗ"
		,"ctrlClass":EditString
		,"ctrlOptions":{
				"name":"EGRZ"
				,"maxLength":"20"
				,"placeholder":"xx-x-x-x-xxxxxx-xxxx или xx-x-x-x-xxxx-xx"
				,"regExpression":/^([0-9]{2}-[1-2]{1}-[1-2]{1}-[1-3]{1}-[0-9]{6}-[0-9]{4})|([0-9]{2}-[1-2]{1}-[1-2]{1}-[1-3]{1}-[0-9]{4}-[0-9]{2})$/				
			}
		}
		,{"dataType":"noEGRZ"
		,"dataTypeDescrLoc":"Номер заключения экспертизы в произвольном формате"
		,"ctrlClass":EditString
		,"ctrlOptions":{
				"name":"noEGRZ"
				,"maxLength":"50"
			}
		}
	];
				
	Conclusion_tConclusionNumber.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tConclusionNumber,EditCompound);

/* Constants */


/* private members */

/* protected*/


/* public methods */

