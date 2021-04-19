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
function Conclusion_tDocument(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("Conclusion_tDocument");
	
	options.addElement = function(){
		
		var lb_col = window.getBsCol(4);
		
		this.addElement(new ConclusionDictionaryDetailEdit(id+":DocType",{			
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Код типа документа:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 6."
			,"conclusion_dictionary_name":"tDocumentType"
			,"focus":true
		}));								

		this.addElement(new EditString(id+":DocName",{			
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"1000"
			,"labelCaption":"Наименование документа:"
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new EditString(id+":DocNumber",{			
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"50"
			,"labelCaption":"Номер документа:"
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new EditDate(id+":DocDate",{			
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"50"
			,"labelCaption":"Дата документа:"
			,"title":"Обязательный элемент."
		}));
										
		
		this.addElement(new EditString(id+":DocIssueAuthor",{			
			"required":false
			,"labelCaption":"Наименование или ФИО автора документа:"
			,"title":"Условно обязательный элемент. Может быть указан для документа, у которого значение 'Код типа документа' не находится в диапазоне от 06.00 до 06.99"
		}));								

		this.addElement(new Conclusion_tDeclarant(id+":FullDocIssueAuthor",{			
			"required":false
			,"labelCaption":"Автор документа с полными реквизитами и адресом"
			,"title":"Условно обязательный элемент. Может быть указан для документа, у которого значение 'Код типа документа' не находится в диапазоне от 06.00 до 06.99"
		}));								
		
		/*this.addElement(new Conclusion_EditCompound(id+":docAuthorContainer",{
			"sysNode":true
			,"name":"docAuthorContainer"
			,"labelCaption":"Наименование или ФИО автора документа:"
			,"possibleDataTypes":[
				{"dataType":"DocIssueAuthor"
				,"dataTypeDescrLoc":"ФИО автора документа"
				,"ctrlClass":EditString					
				,"ctrlOptions":{
					"name":"DocIssueAuthor"
					,"labelCaption":"ФИО автора документа:"
					}
				}
				,{"dataType":"FullDocIssueAuthor"
				,"dataTypeDescrLoc":"Автор документа с полными реквизитами и адресом"
				,"ctrlClass":Conclusion_tDeclarant
				,"ctrlOptions":{
					"name":"FullDocIssueAuthor"
					,"labelCaption":"Автор документа с полными реквизитами и адресом:"
					}
				}
				
			]			
		}));*/
		
		this.addElement(new EditText(id+":DocChanges",{			
			"required":false
			,"maxLength":"255"
			,"labelCaption":"Примечание об изменении документа:"
			,"title":"Необязательный элемент."
		}));								

		//множественная структура!!!
		this.addElement(new Conclusion_Container(id+":File",{			
			"name":"File"
			,"elementControlClass":Conclusion_tFile_View
			,"elementControlOptions":{
				"name":"File"
				,"labelCaption":"Файл:"
			}
			,"deleteTitle":"Удалить файл"
			,"deleteConf":"Удалить файл?"
			,"addTitle":"Добавить файл"
			,"addCaption":"Добавить файл"		
		}));								
		
		
	}
	
	Conclusion_tDocument.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tDocument,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW **********************
function Conclusion_tDocument_View(id,options){
	options = options || {};
	options.viewClass = Conclusion_tDocument;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tDocument_View";
	options.headTitle = "Редактирование документа";
	options.dialogWidth = "50%";
	
	Conclusion_tDocument_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tDocument_View,EditModalDialogXML);

Conclusion_tDocument_View.prototype.formatValue = function(val){
	return	this.formatValueOnTags(
			val
			,[{"tagName":"DocType","ref":true}
			]
		);
}


