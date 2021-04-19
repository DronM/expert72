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
function Conclusion_tForeignAddress(id,options){
	options = options || {};	
	
	options.addElement = function(){
			
		this.addElement(new EditString(id+":Country",{
			"attrs":{"concl_req":true}
			,"maxLength":"200"
			,"labelCaption":"Страна:"
			,"title":"Обязательный элемент."
			,"focus":true
		}));								
		
		this.addElement(new EditText(id+":Note",{
			"attrs":{"concl_req":true}
			,"labelCaption":"Неформализованное описание адреса:"
			,"title":"Необязательный элемент."
		}));								
		
		
	}
	
	Conclusion_tForeignAddress.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tForeignAddress,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tForeignAddress_View(id,options){
	options.viewClass = Conclusion_tForeignAddress;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tForeignAddress_View";
	options.headTitle = "Редактирование иностранного адреса";
	options.dialogWidth = "30%";
	
	Conclusion_tForeignAddress_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tForeignAddress_View,EditModalDialogXML);


