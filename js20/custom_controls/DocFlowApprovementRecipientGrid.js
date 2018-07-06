/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends GridAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function DocFlowApprovementRecipientGrid(id,options){

	var model = new DocFlowApprovementRecipientList_Model({"sequences":{"id":0}});
	this.m_orig_recMove = model.recMove;
	var self = this;
	model.recMove = function(ind,cnt){
		self.m_orig_recMove.call(this,ind,cnt);
		self.calcSteps();
	}
	
	this.m_mainView = options.view;
	
	options = {	
		"model":model,
		"keyIds":["id"],
		"controller":new DocFlowApprovementRecipientList_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerObj(id+":cmd",{
			"cmdSearch":false,
			"cmdExport":false,
			"addCustomCommands":function(commands){
				commands.push(new DocFlowApprovementSelectRecipientTmplCmd(id+":cmd:apply",{
					"mainView":self.m_mainView
				}));
			}		
		}),
		"head":new GridHead(id+":recipient_list:head",{
			"elements":[
				new GridRow(id+":head:row0",{
					"elements":[
						new GridCellHead(id+":head:row0:step",{
							"value":"Шаг",
							"columns":[
								new GridColumn({
									"field":model.getField("step"),
									"ctrlClass":Edit,
									"ctrlOptions":{"enabled":false}
								})							
							]
						})
						,new GridCellHead(id+":head:row0:employee",{
							"value":"С кем согласовать",
							"columns":[
								new GridColumnRef({
									"field":model.getField("employee"),
									"ctrlClass":EmployeeEditRef,
									"form":EmployeeDialog_Form,
									"ctrlBindField":model.getField("employee"),
									"ctrlOptions":{
										"labelCaption":"",
										/*"onSelect":function(f){
											console.dir(f)
										}*/
									}
								})							
							]
						})
						,new GridCellHead(id+":head:row0:employee_comment",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("employee_comment"),
									"ctrlClass":EditString
								})								
							]
						})
						/*						
						,new GridCellHead(id+":head:row0:author_comment",{
							"value":"Комментарий автора",
							"columns":[
								new GridColumn({
									"field":model.getField("author_comment"),
									"ctrlClass":EditString
								})								
							]
						})
						*/												
						,new GridCellHead(id+":head:row0:approvement_order",{
							"value":"Порядок",
							"columns":[
								new EnumGridColumn_doc_flow_approvement_orders({
									"field":model.getField("approvement_order"),
									"ctrlClass":Enum_doc_flow_approvement_orders
								})								
							]
						})						
						,new GridCellHead(id+":head:row0:approvement_dt",{
							"value":"Когда согласовано",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("approvement_dt"),
									"ctrlClass":EditDateTime,
									"ctrlOptions":{
										"editMask":"99/99/9999 99:99",
										"dateFormat":"d/m/Y H:i",
										"cmdClear":false
									}
								})								
							]
						})						
						
						,new GridCellHead(id+":head:row0:approvement_result",{
							"value":"Резальтат",
							"columns":[
								new EnumGridColumn_doc_flow_approvement_results({
									"field":model.getField("approvement_result"),
									"ctrlClass":Enum_doc_flow_approvement_results
								})								
							]
						})						
					
					]
				})
			]
		}),
		"pagination":null,				
		"autoRefresh":false,
		"refreshInterval":0,
		"rowSelect":true
	};
	
	DocFlowApprovementRecipientGrid.superclass.constructor.call(this,id,options);
}
extend(DocFlowApprovementRecipientGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */
DocFlowApprovementRecipientGrid.prototype.edit = function(cmd){
	if (!this.m_mainView.getEnabled()) return;
	
	if (cmd=="edit"){
		var sel_n = this.getSelectedRow();
		this.setModelToCurrentRow(sel_n);
	}
	
	this.m_view = new DocFlowApprovementRecipientEdit(this.getId()+":view:body:view",{
		"ord_vis":(this.m_mainView.getElement("doc_flow_approvement_type").getValue()=="mixed")? true:false,
		"valueJSON":{
			"employee":(cmd=="edit")? this.getModel().getFieldValue("employee") : null
			//,"author_comment":(cmd=="edit")? this.getModel().getFieldValue("author_comment") : null
			,"approvement_order":(cmd=="edit")? this.getModel().getFieldValue("approvement_order") : "after_preceding"
		},
		"template":window.getApp().getTemplate("DocFlowApprovementRecipientEdit")		
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
			if(v.employee)pm.setFieldValue("employee",v.employee);
			//if(v.author_comment)pm.setFieldValue("author_comment",v.author_comment);
			if(v.approvement_order)pm.setFieldValue("approvement_order",v.approvement_order);
			pm.run({
				"ok":function(){
					self.calcSteps();					
					self.closeSelect();
				}
			});
		},				
		"content":this.m_view,
		"contentHead":"Редактирование строки"
	});

	this.m_form.open();
}
DocFlowApprovementRecipientGrid.prototype.closeSelect = function(){
	if (this.m_view){
		this.m_view.delDOM();
		delete this.m_view;
	}
	if (this.m_form){
		this.m_form.close();
		delete this.m_form;
	}		
}

DocFlowApprovementRecipientGrid.prototype.calcSteps = function(){
	var m = this.getModel();
	var appr_order = this.m_mainView.getElement("doc_flow_approvement_type").getValue();
	var step = 0;
	m.reset();
	while(m.getNextRow()){
		step +=
		((appr_order=="to_one")
		|| (appr_order=="mixed" && m.getFieldValue("approvement_order")=="after_preceding")
		|| (!step)
		)? 1:0;
		m.m_currentRow.fields.step = step;
	}
	this.onRefresh();
}

DocFlowApprovementRecipientGrid.prototype.afterServerDelRow = function(){	
	DocFlowApprovementRecipientGrid.superclass.afterServerDelRow.call(this);
	
	this.calcSteps();
}
