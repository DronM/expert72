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
function Conclusion_tObject(id,options){
	options = options || {};	
	
	options.addElement = function(){
		
		var lb_col = window.getBsCol(4);
		
		this.addElement(new EditText(id+":Name",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"1000"
			,"labelCaption":"Наименование объекта капитального строительства:"
			,"placeholder":"Наименование объекта"
			,"title":"Обязательный элемнт."
		}));								
	
		this.addElement(new Conclusion_Container(id+":addressContainer",{
			"xmlNodeName":"addressContainer"
			,"elementControlClass":Conclusion_EditCompound
			,"elementControlOptions":{
				"sysNode":true
				,"name":"addressContainer"
				,"controlNameToConclusionTagName":true
				,"possibleDataTypes":[
					{"dataType":"Address"
					,"dataTypeDescrLoc":"Адрес объекта в РФ"
					,"ctrlClass":Conclusion_tAddress_View
					,"ctrlOptions":{
						"required":true
						,"labelClassName":"control-label contentRequired "+lb_col
						,"labelCaption":"Адрес объекта капитального строительства в пределах РФ:"
						,"name":"Address"
						}
					}
					,{"dataType":"ForeignAddress"
					,"dataTypeDescrLoc":"Адрес объекта за пределами РФ"
					,"ctrlClass":Conclusion_tForeignAddress_View
					,"ctrlOptions":{
						"required":true
						,"labelClassName":"control-label contentRequired "+lb_col
						,"labelCaption":"Адрес объекта капитального строительства за пределами РФ:"
						,"name":"ForeignAddress"
						}
					}
					
				]
				,"labelCaption":"Адрес объекта капитального строительства:"		
			}
			,"deleteTitle":"Удалить адрес"
			,"deleteConf":"Удалить адрес?"
			,"addTitle":"Добавить адрес"
			,"addCaption":"Добавить адрес"
		}));								

		this.addElement(new ConclusionDictionaryDetailSelect(id+":Type",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вид объекта капитального строительства:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 7."
			,"conclusion_dictionary_name":"tObjectType"
		}));								

		this.addElement(new Conclusion_EditCompound(id+":functionContainer",{
			"sysNode":true
			,"name":"functionContainer"
			,"controlNameToConclusionTagName":true
			,"labelCaption":"Функциональное назначение объекта капитального строительства:"
			,"possibleDataTypes":[
				{"dataType":"Functions"
				,"dataTypeDescrLoc":"Произвольный текст"
				,"ctrlClass":EditText					
				,"ctrlOptions":{
					"name":"Functions"
					,"labelCaption":"Функциональное назначение объекта капитального строительства:"
					}
				}
				,{"dataType":"FunctionsClass"
				,"dataTypeDescrLoc":"Код по классификатору"
				,"ctrlClass":EditString
				,"ctrlOptions":{
					"name":"FunctionsClass"
					,"labelCaption":"Функциональное назначение объекта капитального строительства (код по классификатору)"
					,"title":"Обязательный элемент.Формат xx.xx.xxx.xxx или xx.xx.xxx"
					,"placeholder":"xx.xx.xxx.xxx или xx.xx.xxx"
					,"regExpression":/^([0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,3})|([0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3})$/
					}
				}
				
			]			
		}));

		this.addElement(new Conclusion_Container(id+":TEI",{
			"name":"TEI"
			,"xmlNodeName":"TEI"
			,"elementControlClass":Conclusion_tTEI_View
			,"elementControlOptions":{
				"labelCaption":"Технико-экономический показатель показатель:"
				,"name":"TEI"
			}
			,"deleteTitle":"Удалить технико-экономический показатель показатель"
			,"deleteConf":"Удалить технико-экономический показатель показатель?"
			,"addTitle":"Добавить технико-экономический показатель"
			,"addCaption":"Добавить показатель"
		}));								
		
		this.addElement(new Conclusion_Container(id+":ObjectPart",{
			"name":"ObjectPart"
			,"xmlNodeName":"ObjectPart"
			,"elementControlClass":Conclusion_tObjectPart_View
			,"elementControlOptions":{
				"labelCaption":"Описание составной части сложного объекта:"
				,"name":"ObjectPart"
			}
			,"deleteTitle":"Удалить часть сложного объекта"
			,"deleteConf":"Удалить часть?"
			,"addTitle":"Добавить часть сложного объекта"
			,"addCaption":"Добавить часть сложного объекта"
		}));								

	}
	
	Conclusion_tObject.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tObject,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tObject_View(id,options){

	options.viewClass = Conclusion_tObject;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tObject_View";
	options.headTitle = "Сведения об объекте капитального строительства";
	options.dialogWidth = "80%";
	
	Conclusion_tObject_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tObject_View,EditModalDialogXML);

Conclusion_tObject_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"Name"}
			]
		)
	;
}


