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
function Conclusion_tExpert(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);	
	
		var self = this;
		var emp_contr = new Employee_Controller();
		this.m_certContr = new EmployeeExpertCertificate_Controller(); 
		var emp_model = new EmployeeWithExpertCertificateList_Model();
		var cert_model = new EmployeeExpertCertificateList_Model();
		
		this.addElement(new EditString(id+":FamilyName",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxlength":"100"
			,"labelCaption":"Фамилия:"
			,"placeholder":"Фамилия эксперта"
			,"title":"Обязательный элемнт."
			,"regExpression":/^[-а-яА-ЯёЁ\s]+$/
			,"cmdAutoComplete":true
			,"acMinLengthForQuery":1
			,"acController":emp_contr
			,"acModel":emp_model
			,"acPublicMethod":emp_contr.getPublicMethod("complete_with_expert_cert")
			,"acPatternFieldId": "name"
			,"acKeyFields":[emp_model.getField("name")]
			,"acDescrFields":[emp_model.getField("name")]
			,"acICase":"1"
			,"acMid": "1"
			,"onSelect":function(f){
				//complete fields
				var nm = f["name"].getValue();
				if(nm&&nm.length){
					var nm_parts = nm.split(" ");
					if(nm_parts.length>=1){
						self.getElement("FamilyName").setValue(nm_parts[0]);
					}
					if(nm_parts.length>=2){
						self.getElement("FirstName").setValue(nm_parts[1]);
					}else{
						self.getElement("FirstName").setValue("");
					}
					if(nm_parts.length>=3){
						self.getElement("SecondName").setValue(nm_parts[2]);
					}else{
						self.getElement("SecondName").setValue("");
					}
				}
				
				var cert_list = f["cert_list"].getValue();
				if(cert_list&&cert_list.length){
					self.setCert(cert_list[0]);
					
				}
				
				self.m_certContr.getPublicMethod("complete_on_cert_id").setFieldValue("employee_id",f["id"].getValue());
			}
			,"onReset":function(){
				self.m_certContr.getPublicMethod("complete_on_cert_id").unsetFieldValue("employee_id");
			}
			,"focus":true
		}));								
	
		this.addElement(new EditString(id+":FirstName",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"maxlength":"100"
			,"labelCaption":"Имя:"
			,"placeholder":"Имя эксперта"
			,"title":"Обязательный элемнт."
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
		}));								
	
		this.addElement(new EditString(id+":SecondName",{
			"maxlength":"50"
			,"labelCaption":"Отчество:"
			,"placeholder":"Отчество эксперта"
			,"title":"Не обязательный элемнт."
			,"regExpression":/^[а-яА-ЯёЁ\s]+$/
		}));								
		
		this.addElement(new ConclusionDictionaryDetailEdit(id+":ExpertType",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"labelCaption":"Направление деятельности эксперта, согласно квалификационному аттестату:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 11."
			,"conclusion_dictionary_name":"tExpertType"
		}));								

		this.addElement(new EmployeeExpertCertificateId(id+":ExpertCertificate",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"cmdAutoComplete":true
			,"acMinLengthForQuery":1
			,"acController":this.m_certContr
			,"acModel":cert_model
			,"acPublicMethod":this.m_certContr.getPublicMethod("complete_on_cert_id")
			,"acPatternFieldId": "cert_id"
			,"acKeyFields":[cert_model.getField("cert_id")]
			,"acDescrFields":[cert_model.getField("cert_id")]
			,"acICase":"1"
			,"acMid": "1"
			,"onSelect":function(f){
				//complete fields
				self.setCert({
					"expert_types_ref":f.expert_types_ref.getValue()
					,"cert_id":f.cert_id.getValue()
					,"date_from":f.date_from.getValue()
					,"date_to":f.date_to.getValue()
				});
			}			
		}));								
		
		this.addElement(new EditDate(id+":ExpertCertificateBeginDate",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"labelCaption":"Дата выдачи квалификационного аттестата:"
			,"title":"Обязательный элемент"
		}));								
		
		this.addElement(new EditDate(id+":ExpertCertificateEndDate",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"labelCaption":"Дата окончания действия квалификационного аттестата:"
			,"title":"Обязательный элемент"
		}));								
	}
	
	Conclusion_tExpert.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tExpert,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */
Conclusion_tExpert.prototype.setCert = function(certObj){
	this.getElement("ExpertType").setValue(certObj.expert_types_ref);
	this.getElement("ExpertCertificate").setValue(certObj.cert_id);
	this.getElement("ExpertCertificateBeginDate").setValue(certObj.date_from);
	this.getElement("ExpertCertificateEndDate").setValue(certObj.date_to);
}


//****************** VIEW **********************
function Conclusion_tExpert_View(id,options){

	options.viewClass = Conclusion_tExpert;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tExpert_View";
	options.headTitle = "Перечень лиц, аттестованных на право подготовки заключений экспертизы";
	options.dialogWidth = "80%";
	
	Conclusion_tExpert_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tExpert_View,EditModalDialogXML);

Conclusion_tExpert_View.prototype.formatValue = function(val){
	var res = "";
	if(val){
		var n;
		
		n = val.getElementsByTagName("FamilyName");
		if(n&&n.length&&n[0].textContent){
			res = n[0].textContent;
		}
		n = val.getElementsByTagName("FirstName");
		if(n&&n.length&&n[0].textContent){
			res = res + " " + n[0].textContent;
		}
		n = val.getElementsByTagName("SecondName");
		if(n&&n.length&&n[0].textContent){
			res = res + " " + n[0].textContent;
		}
	}	
	return res;	
}

