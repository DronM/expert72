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
function Conclusion_tCadastralNumber(id,options){
	options = options || {};	
	
	options.addElement = function(){
		//Выбор из двух
		this.addElement(new Conclusion_tOrganization(id+":Organization",{
			"attrs":{"concl_req":true}
			,"labelCaption":"Технический заказчик – Юридическое лицо:"
			,"title":"Обязательный элемнт."
		}));								
	
		this.addElement(new Conclusion_tOrganization(id+":tForeignOrganization",{
			"attrs":{"concl_req":true}
			,"labelCaption":"Технический заказчик – Иностранное юридическое лицо (представительство, филиал):"
			,"title":"Обязательный элемнт."
		}));								
	
	}
	
	Conclusion_tCadastralNumber.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tCadastralNumber,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tCadastralNumber_View(id,options){

	options.viewClass = Conclusion_tCadastralNumber;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tCadastralNumber_View";
	options.headTitle = "Редактирование технического заказчика";
	options.dialogWidth = "30%";
	
	Conclusion_tCadastralNumber_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tCadastralNumber_View,EditModalDialogXML);
