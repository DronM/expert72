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
function Conclusion_tEstimatedSum(id,options){
	options = options || {};	
	
	options.placeholder = "Не требуется/Отсутствует/тыс.руб.";
	options.title = "Обязательный элемент.Возможные значения: Не требуется,Отсутствует,сумма";
	options.regExpression = /^(Не требуется)$|^(Отсутствует)$|^([+-]?\d+(\.\d+)?)$/;
	options.m_validator = new ValidatorString();
	
	Conclusion_tEstimatedSum.superclass.constructor.call(this,id,options);
	
	//complete
	//this.m_compl = actb(this.m_node,options.winObj);
	//this.m_compl.actb_keywords = ["Не требуется","Отсутствует"];
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tEstimatedSum,EditString);

/* Constants */


/* private members */

/* protected*/


/* public methods */

