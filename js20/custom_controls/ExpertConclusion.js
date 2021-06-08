/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends EditXML
 * @requires core/extend.js
 * @requires controls/EditXML.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {object} options.conclusion_type 
 */
function ExpertConclusion(id,options){
	options = options || {};	
	//alert("ExpertConclusion")
	options.addElement = function(){

		if(options.conclusion_type == "eng"){
			this.addElement(new Conclusion_tExpertEngineeringSurveys(id+":ExpertEngineeringSurveys",{			
			}));
			
		}else if(options.conclusion_type == "pd"){
			this.addElement(new Conclusion_tExpertProjectDocuments(id+":ExpertProjectDocuments",{			
			}));
			
		}else if(options.conclusion_type == "val_estim"){
			this.addElement(new Conclusion_tExpertEstimate(id+":ExpertEstimate",{			
			}));
		}
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
