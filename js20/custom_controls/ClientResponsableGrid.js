/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends GridAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ClientResponsableGrid(id,options){
	options = options || {};
	
	this.m_mainView = options.mainView;
	this.m_clientEditView = options.clientEditView;
	this.m_minInf = options.minInf;

	var model = new ClientResponsablePerson_Model({
		"sequences":{"id":0}
	});

	var cells = [
		new GridCellHead(id+":head:dep",{
			"value":"Отдел",
			"columns":[
				new GridColumn({"field":model.getField("dep")})
			]
		}),					
		new GridCellHead(id+":head:name",{
			"value":"ФИО",
			"columns":[
				new GridColumn({
					"field":model.getField("name")
				})
			],
			"sortable":true,
			"sort":"asc"
		}),
		new GridCellHead(id+":head:post",{
			"value":"Должность",
			"columns":[
				new GridColumn({"field":model.getField("post")})
			]
		}),
		new GridCellHead(id+":head:tel",{
			"value":"Телефон",
			"columns":[
				new GridColumnPhone({
					"field":model.getField("tel"),
					"ctrlClass":EditPhone
				})
			]
		}),
		new GridCellHead(id+":head:email",{
			"value":"Эл.почта",
			"columns":[
				new GridColumnEmail({
					"field":model.getField("email"),
					"ctrlClass":EditEmail
				})
			]
		})
	];

	if (window.getApp().getServVar("role_id")!="client"){
		cells.push(
			new GridCellHead(id+":head:person_type",{
				"value":"Вид должн.лица",
				"columns":[
					new EnumGridColumn_responsable_person_types({
						"field":model.getField("person_type"),
						"ctrlClass":Enum_responsable_person_types,
						"ctrlOptions":{"required":true}									
					})
				]
			})																		
		);
	}
	
	var cmd_cap = this.getCmdCaptionsOnClientType(this.m_clientEditView.getElement("client_type").getValue());
	
	var self = this;
	options = {
		"model":model,
		"keyIds":["id"],
		"controller":new ClientResponsablePerson_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdSearch":false,
			"cmdExport":false,
			"addCustomCommandsAfter":function(cmd){
				cmd.push(
					new GridCmd(id+":cmd:copyFromRepHead",{
						"showCmdControl":true,
						"glyph":"glyphicon-arrow-down",
						"title":cmd_cap.title,
						"caption":cmd_cap.caption,
						"onCommand":function(){
							var m = self.getModel();
							m.clear();
							m.setFieldValue("id",m.getRowCount()+1);
							
							var cl_tp = self.m_clientEditView.getElement("client_type").getValue();
							if(cl_tp=="enterprise"){
								var p = self.m_clientEditView.getElement("responsable_person_head").getValueJSON();								
								m.setFieldValue("name",p["name"]);
								m.setFieldValue("post",p["post"]);
								m.setFieldValue("tel",p["tel"]);
								m.setFieldValue("email",p["email"]);
							}
							else{
								m.setFieldValue("name",self.m_clientEditView.getElement("name_full").getValue());
								m.setFieldValue("post",cl_tp=="pboul"? "Руководитель":"");
								m.setFieldValue("tel","");
								m.setFieldValue("email",self.m_clientEditView.getElement("corp_email").getValue());
							}	
							m.recInsert();
							self.onRefresh(function(){
								self.m_mainView.calcFillPercent();
							});
						}				
					})
				);
			}
		}),
		"head":new GridHead(id+":head",{
			"elements":[
				new GridRow(id+":head:row0",{
					"elements":cells
				})
			]
		}),
		"pagination":null,				
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":true
	};
	
	this.m_orig_afterServerDelRow = this.afterServerDelRow;
	this.afterServerDelRow = function(){
		if (this.m_mainView){
			this.m_mainView.calcFillPercent();
		}
		this.m_orig_afterServerDelRow();
	}
	/*
	this.m_orig_refreshAfterEdit = this.refreshAfterEdit;
	this.refreshAfterEdit = function(res){
		console.log("this.refreshAfterEdit")
		if (this.m_mainView && res && res.updated){
			this.m_mainView.calcFillPercent();
		}
		this.m_orig_refreshAfterEdit(res);
	}
	*/	
	ClientResponsableGrid.superclass.constructor.call(this,id,options);
}
extend(ClientResponsableGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
/**
 * В зависимости от типа контрагента отключает некоторые колнки
 */
ClientResponsableGrid.prototype.setClientType = function(ctp){
	this.m_clientType = ctp;
	this.setColumnVisible(["dep","post","person_type"],(ctp!="person"));
}

ClientResponsableGrid.prototype.getFillPercent = function(){
	var percent = 0;
	if (this.m_minInf){
		percent = 100;
	}
	else if (this.getModel().getRowCount()){
		this.getModel().setRowIndex(0);
		percent = this.getModel().getField("name").isSet()? 50:0;
		percent += ((this.getModel().getField("email").isSet()||this.getModel().getField("tel").isSet())? 50:0);
	}
	this.setAttr("title","Заполнено на "+percent+"%");
	//this.setAttr("fill_percent",(percent==100)? 100 : ( (percent<50)? 0:50 ));
	if (percent>0 && percent<100){
		DOMHelper.addClass(this.m_node,"null-ref");
	}
	else{
		DOMHelper.delClass(this.m_node,"null-ref");
	}
	
	return percent;
}

ClientResponsableGrid.prototype.edit = function(cmd){
	if (cmd=="edit"){
		var sel_n = this.getSelectedRow();
		this.setModelToCurrentRow(sel_n);
	}
	
	this.m_view = new ClientResponsablePersonEdit(this.getId()+":view:body:view",{
		"calcPercent":(this.m_mainView!=undefined)? true:false,
		"clientTypePerson":(this.m_clientType=="person"),
		"valueJSON":{
			"dep":(cmd=="edit" && this.m_clientType!="person")? this.getModel().getFieldValue("dep") : null
			,"name":(cmd=="edit")? this.getModel().getFieldValue("name") : null
			,"post":(cmd=="edit" && this.m_clientType!="person")? this.getModel().getFieldValue("post") : null
			,"tel":(cmd=="edit")? this.getModel().getFieldValue("tel") : null
			,"email":(cmd=="edit")? this.getModel().getFieldValue("email") : null
			,"person_type":(cmd=="edit" && this.m_clientType!="person")? this.getModel().getFieldValue("person_type") : null
		}
		//,"template":window.getApp().getTemplate("DocFlowApprovementRecipientEdit")		
	});
	var self = this;
	this.m_form = new WindowFormModalBS(this.getId()+":form",{
		"cmdCancel":true,
		"controlCancelCaption":this.BTN_CANCEL_CAP,
		"controlCancelTitle":this.BTN_CANCEL_TITLE,
		"cmdOk":true,
		"controlOkCaption":this.BTN_OK_CAP,
		"controlOkTitle":this.BTN_OK_TITLE,
		"onClickCancel":function(){
			self.closeSelect();
		},		
		"onClickOk":function(){
			var v = self.m_view.getValueJSON();
			var pm = (cmd=="edit")? self.getUpdatePublicMethod() : self.getInsertPublicMethod();
			if(cmd=="edit")pm.setFieldValue("old_id",self.getModel().getFieldValue("id"));
			if(!v.dep&&!v["name"]&&!v["post"]&&!v["email"]&&!v["tel"]&&!v["person_type"])return;
			if(v.dep && self.m_clientType!="person")pm.setFieldValue("dep",v.dep);
			pm.setFieldValue("name",v["name"]);
			pm.setFieldValue("post",v["post"]);
			pm.setFieldValue("email",v["email"]);
			pm.setFieldValue("tel",v["tel"])
			if(v["person_type"] && self.m_clientType!="person")pm.setFieldValue("person_type",v["person_type"]);
			
			pm.run({
				"ok":function(){
					self.closeSelect();
					self.onRefresh(function(){
						if(self.m_mainView)self.m_mainView.calcFillPercent();
					});
				}
			});
		},				
		"content":this.m_view,
		"contentHead":"Редактирование контакта"
	});

	this.m_form.open();
}
ClientResponsableGrid.prototype.closeSelect = function(){
	if (this.m_view){
		this.m_view.delDOM();
		delete this.m_view;
	}
	if (this.m_form){
		this.m_form.close();
		delete this.m_form;
	}		
}

ClientResponsableGrid.prototype.getCmdCaptionsOnClientType = function(clType){
	var res = {"caption":"","title":""};
	if(clType=="enterprise"){		
		res.caption = "Руководитель ";
		res.title = "Подставить данные руководителя";
	}
	else if(clType=="pboul"){
		res.caption = "Данные ИП ";
		res.title = "Подставить данные иднивидулального предпринимателя";
	}
	else if(clType=="person"){
		res.caption = "Данные ФЛ ";
		res.title = "Подставить данные физического лица";
	}
	return res;
}

ClientResponsableGrid.prototype.onChangeClientType = function(){
	var cmd_cap = this.getCmdCaptionsOnClientType(this.m_clientEditView.getElement("client_type").getValue());
	this.getCommands().getElement("copyFromRepHead").setCaption(cmd_cap.caption);
	this.getCommands().getElement("copyFromRepHead").setAttr("title",cmd_cap.title);
}
