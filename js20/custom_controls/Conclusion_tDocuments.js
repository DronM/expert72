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
function Conclusion_tDocuments(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("Conclusion_tDocuments");
	
	this.m_parentContainer = options.parentContainer;
	
	options.addElement = function(){
		var self = this;
		//fill on 
		this.addElement(new ButtonCmd(id+":fillOnDesigner",{
			"caption":"Установить автора документов РИИ",
			"title":"Выбрать исполнителя для заполнения автора докумнтов РИИ",
			"onClick":function(e){
				self.fillOnDesigner(e);
			},
			"attrs":{"notForValue":"true"}
		}));
	
		this.addElement(new Conclusion_Container(id+":Document",{
			"name":"Document"
			,"xmlNodeName":"Document"
			,"elementControlClass":Conclusion_tDocument_View
			,"elementControlOptions":{
				"labelCaption":"Документ:"
				,"name":"Document"
			}
			,"deleteTitle":"Удалить документ, представленный для проведения экспертизы"
			,"deleteConf":"Удалить документ?"
			,"addTitle":"Добавить документ, представленный для проведения экспертизы"
			,"addCaption":"Добавить документ"
		}));								
	}
	
	Conclusion_tDocuments.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tDocuments,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

Conclusion_tDocuments.prototype.fillOnDesignerCont = function(orgConclVal){
	//Iterate all eng_survey documents
	var cont = this.getElement("Document").m_container.getElements();
	for(var id in cont){
		var doc = cont[id].getElement("Document");
		var xml = doc.getValue();
		if(xml.childNodes&&xml.childNodes.length){
			var doc_type = xml.getElementsByTagName("DocType");
			if(doc_type && doc_type.length){
				var doc_v = doc_type[0].getElementsByTagName("conclusionValue");
				if(doc_v&&doc_v.length && doc_v[0].textContent.substr(0,2)=="06"){
					debugger
					var doc_author = xml.getElementsByTagName("FullDocIssueAuthor");					
					if(doc_author && doc_author.length){
						doc_author[0].remove()
					}
					var new_org_doc = DOMHelper.xmlDocFromString("<FullDocIssueAuthor>"+
						orgConclVal.outerHTML+
						"<sysValue skeepNode='TRUE'>Organization</sysValue>"+
						"</FullDocIssueAuthor>"
					);
					var file_node = xml.getElementsByTagName("File");
					if(file_node&&file_node.length){
						xml.insertBefore(new_org_doc.childNodes[0],file_node[0]);
						doc.setValue(xml);
					}
					//console.log(xml)
				}
			}
		}
	}
}

Conclusion_tDocuments.prototype.fillOnDesigner = function(e){
	//выбрать исполнителя, всех в список
	var designer_list = [];
	var cont = this.m_parentContainer.getElement("Designer").m_container.getElements();
	var ind = 0;
	var self = this;
	for(var id in cont){
		var xml = cont[id].getElement("Designer").getValue();
		if(xml.childNodes&&xml.childNodes.length){
			var org = xml.childNodes[0].getElementsByTagName("orgType");
			if(org&&org.length){
				var org_v = org[0].getElementsByTagName("conclusionValue");
				if(org_v&&org_v.length){
					var org_v_full_n = org_v[0].getElementsByTagName("OrgFullName");
					if(org_v_full_n&&org_v_full_n.length){
						var org_v_inn = org_v[0].getElementsByTagName("OrgINN");					
						//action
						designer_list.push({
							"id":ind
							,"onClick":(function(orgNode){
								return function(){
									self.fillOnDesignerCont(orgNode);
								}
							})(org_v[0])
							,"caption":org_v_full_n[0].textContent+(org_v_inn&&org_v_inn.length? " "+org_v_inn[0].textContent:"")
						});
					}
				}
			}
		}
		ind++;
	}
	var popup = new PopUpMenu({
		"caption":"Исполнители"
		,"elements":designer_list
	})
	popup.show(e,this.getElement("fillOnDesigner").getNode());
	
	
}

//****************** VIEW ********************** Не используется!
function Conclusion_tDocuments_View(id,options){
	options.viewClass = Conclusion_tDocuments;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tDocuments_View";
	options.headTitle = "Редактирование состава документов";
	options.dialogWidth = "80%";
	
	Conclusion_tDocuments_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tDocuments_View,EditModalDialogXML);

