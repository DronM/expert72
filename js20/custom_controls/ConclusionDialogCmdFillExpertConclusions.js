/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends ButtonCmd
 * @requires core/extend.js
 * @requires controls/ButtonCmd.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ConclusionDialogCmdFillExpertConclusions(id,options){
	options = options || {};	
	
	options.caption = " Заполнить по заключениям экспертов";
	options.title = "Загрузить все заключения, выполненные экспертами";
	options.glyph = "glyphicon-repeat";
	
	this.m_docView = options.docView;
	
	var self = this;
	options.onClick = function(){
		if(!self.m_docView.getModified()){
			self.fillExpertConclusions();
			
		}else{
			self.m_docView.onSave(
				function(){
					self.fillExpertConclusions();
				}
			);
		}
	}
	
	ConclusionDialogCmdFillExpertConclusions.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ConclusionDialogCmdFillExpertConclusions,ButtonCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
ConclusionDialogCmdFillExpertConclusions.prototype.fillExpertConclusionsCont = function(){

	var contracts_ref = this.m_docView.getElement("contracts_ref").getValue();
	if(!contracts_ref && contracts_ref.isNull()){
		return;
	}

	var pm = (new Conclusion_Controller()).getPublicMethod("fill_expert_conclusions");
	pm.setFieldValue("doc_id", contracts_ref.getKey("id"));
	pm.setFieldValue("tm", (new Date).getTime());
	
	window.setGlobalWait(true);
	var docView = this.m_docView;
	pm.run({
		"ok":function(resp){
			//XML result!			
			if(resp.childNodes && resp.childNodes.length){
				for (var i=0;i<resp.childNodes[0].childNodes.length;i++){					
					var nm = resp.childNodes[0].childNodes[i].nodeName;
					var ctrl;
					
					if(nm == "pd"){
						ctrl = docView.getElement("Conclusion").getElement("ExpertProjectDocuments");
					}
					else if(nm == "eng"){
						ctrl = docView.getElement("Conclusion").getElement("ExpertEngineeringSurveys");
					}
					else if(nm == "val_estim"){
						ctrl = docView.getElement("Conclusion").getElement("ExpertEstimate");
					}
					ctrl.getElement("container").clear();
					var nd = resp.childNodes[0].childNodes[i];
					for (k=0;k<nd.childNodes.length;k++){
						var new_elem = ctrl.createNewElement();
						new_elem.setValue(nd.childNodes[k]);
						
						ctrl.m_container.addElement(new_elem);						
						new_elem.toDOM(ctrl.m_container.getNode());
						ctrl.addPanelEvents();
						
					}
				}
			}
			window.showTempNote("Заключения экспертов загружены");
		}
		,"all":function(){
			window.setGlobalWait(false);
		}
	});
}

ConclusionDialogCmdFillExpertConclusions.prototype.fillExpertConclusions = function(){
	var self = this;
	WindowQuestion.show({
		"no":false
		,"text":"Заполнить по данным заключений экспертов?"
		,"callBack":function(res){
			if (res == WindowQuestion.RES_YES){
				self.fillExpertConclusionsCont();
			}
		}
	});
}

