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
function Conclusion_tMismatch(id,options){
	options = options || {};	
	
	options.addElement = function(){

		var lb_col = window.getBsCol(4);
	
		this.addElement(new EditText(id+":Summary",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вывод о несоответствии:"
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new EditText(id+":Part",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Ссылка на материалы, в отношении которых сделан вывод о несоответствии:"
			,"title":"Обязательный элемент."
		}));								
		
		var ctrl_link = new EditText(id+":linkSys",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Ссылка на конкретное требование, несоответствие которому было выявлено в ходе экспертизы:"
			,"title":"Обязательный элемент."
		});
		this.addElement(ctrl_link);								
		ctrl_link.m_xmlAttrs = {
			"conclusionTagName":"Link"
		};
		
	}
	
	Conclusion_tMismatch.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tMismatch,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */


//****************** VIEW **********************
function Conclusion_tMismatch_View(id,options){
	options = options || {};
	options.viewClass = Conclusion_tMismatch;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tMismatch_View";
	options.headTitle = "Сведения о несоответствии'";
	options.dialogWidth = "50%";
	
	Conclusion_tMismatch_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tMismatch_View,EditModalDialogXML);

