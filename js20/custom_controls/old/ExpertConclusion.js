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
function ExpertConclusion(id,options){
	options = options || {};	
	
	options.addElement = function(){
		var lb_col = window.getBsCol(4);
		
		this.addElement(new Conclusion_tExperts(id+":Experts",{
			"name":"Experts"
			,"required":true
			,"title":"Список экспертов. Обязательный элемент."
		}));										

	}
	
	ExpertConclusion.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ExpertConclusion,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ExpertConclusion.prototype.validate = function(){
	return true;
}
