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
function Conclusion_tDesigner(id,options){
	options = options || {};	
	
	
	options.addElement = function(){
	
		this.addElement(new Conclusion_EditCompound(id+":orgType",{
			"sysNode":true
			,"labelCaption":"Проектная организация:"
			,"controlNameToConclusionTagName":true
			,"possibleDataTypes":[
				{"dataType":"Organization"
				,"dataTypeDescrLoc":"Проектная организация - Юридическое лицо"
				,"ctrlClass":Conclusion_tOrganization_View
				,"ctrlOptions":{
						"name":"Organization"
					}
				}
				,{"dataType":"ForeignOrganization"
				,"dataTypeDescrLoc":"Проектная организация - Иностранное юридическое лицо"
				,"ctrlClass":Conclusion_tForeignOrganization_View
				,"ctrlOptions":{
						"name":"ForeignOrganization"
					}
				}
				,{"dataType":"IP"
				,"dataTypeDescrLoc":"Проектная организация - Индивидуальный предприниматель"
				,"ctrlClass":Conclusion_tIP_View
				,"ctrlOptions":{
						"name":"IP"
					}
				}			
			]
		}));
		
		this.addElement(new EditSelect(id+":General",{
			"attrs":{"xmlAttr":true}
			,"labelCaption":"Генеральный проектировщик:"
			,"elements":[
				new EditSelectOption(id+":General:no",{
					"descr":"Нет","value":"нет"
				})
				,new EditSelectOption(id+":General:yes",{
					"descr":"Да","value":"да"
				})
			]
		}));
	}	
	
	Conclusion_tDesigner.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tDesigner,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


