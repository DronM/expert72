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
function Conclusion_tExperts(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		this.addElement(new Conclusion_Container(id+":Expert",{
			"name":"Expert"
			,"xmlNodeName":"Expert"
			,"elementControlClass":Conclusion_tExpert_View
			,"elementControlOptions":{				
				"labelCaption":"Эксперт:"
				,"name":"Expert"
			}
			,"deleteTitle":"Удалить эксперта"
			,"deleteConf":"Удалить эксперта?"
			,"addTitle":"Добавить эксперта"
			,"addCaption":"Добавить эксперта"		
		}));								
	}
	
	Conclusion_tExperts.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tExperts,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */



