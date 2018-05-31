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

	options = {
		"model":model,
		"keyIds":["id"],
		"controller":new ClientResponsablePerson_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":cmd",{
			"cmdSearch":false,
			"cmdExport":false
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
	this.m_orig_refreshAfterEdit = this.refreshAfterEdit;
	this.refreshAfterEdit = function(res){
		if (this.m_mainView && res && res.updated){
			this.m_mainView.calcFillPercent();
		}
		this.m_orig_refreshAfterEdit(res);
	}
		
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
	return ( (this.getModel().getRowCount()||this.m_minInf)? 100:0);
}

ClientResponsableGrid.prototype.edit = function(cmd){
	if (cmd=="edit"){
		var sel_n = this.getSelectedRow();
		this.setModelToCurrentRow(sel_n);
	}
	
	this.m_view = new ClientResponsablePersonEdit(this.getId()+":view:body:view",{
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
			
			if(v.dep && self.m_clientType!="person")pm.setFieldValue("dep",v.dep);
			pm.setFieldValue("name",v["name"]);
			pm.setFieldValue("post",v["post"]);
			pm.setFieldValue("email",v["email"]);
			if(v["person_type"] && self.m_clientType!="person")pm.setFieldValue("person_type",v["person_type"]);
			
			/*
			if(v["name"])pm.setFieldValue("name",v["name"]);
			if(v["post"] && self.m_clientType!="person")pm.setFieldValue("post",v["post"]);
			if(v["tel"])pm.setFieldValue("tel",v["tel"]);
			if(v["email"])pm.setFieldValue("email",v["email"]);
			if(v["person_type"] && self.m_clientType!="person")pm.setFieldValue("person_type",v["person_type"]);
			*/
			pm.run({
				"ok":function(){
					self.closeSelect();
					self.onRefresh();
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

