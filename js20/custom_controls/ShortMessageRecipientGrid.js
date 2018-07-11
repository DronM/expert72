/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends GridAjx
 * @requires core/extend.js
 * @requires controls/GridAjx.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function ShortMessageRecipientGrid(id,options){
	options = options || {};	
	
	this.m_getStateClass = options.getStateClass;
	this.m_hideView = options.hideView;
	this.m_showView = options.showView;
	
	var model = new ShortMessageRecipientList_Model();
	var contr = new ShortMessage_Controller();
	
	var popup_menu = null;//new PopUpMenu();
	
	var self = this;
	
	var gr_options = {
		"model":model,
		"keyIds":["recipient_id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"readPublicMethod":contr.getPublicMethod("get_recipient_list"),
		"showHead":false,
		"navigate":false,
		"navigateClick":false,
		"className":"noBorder",
		"onEventSetRowOptions":function(opts){
			if (!this.getModel().getFieldValue("is_online")){
				opts.className = ((opts.className&&opts.className.length)? opts.className+" ":"")+"noBorder recipientUnavail recipient";
				opts.attrs = opts.attrs||{};
				opts.attrs.title="Не в сети";				
			}
			else{				
				var cl = this.m_getStateClass(this.getModel().getFieldValue("recipient_states_ref").getKey("id"));
				opts.className = ((opts.className&&opts.className.length)? opts.className+" ":"")+"noBorder recipient "+cl;
				opts.attrs.title="В сети. "+this.getModel().getFieldValue("recipient_states_ref").getDescr()+".";
			}
			opts.events = {
				"click":function(e){
					if (e.target.tagName!="INPUT"){
						self.getModel().getRow(this.getAttr("modelindex"));
						self.openMessageForm(self.getModel().getFields());
					}
				}
			}
		},
		"onEventSetCellOptions":function(opts){
			opts.className = ((opts.className&&opts.className.length)? opts.className+" ":"")+"noBorder";
		},
		"commands":new GridCmdContainer(id+":cmd",{
			"cmdSearch":false,
			"cmdExport":false,
			"cmdInsert":false,
			"cmdEdit":false,
			"cmdAllCommands":false,
			"addCustomCommands":function(commands){
				commands.push(new GridCmd(id+":cmd:check",{
					"showCmdControl":true,
					"glyph":"glyphicon glyphicon-check",
					"buttonClass":ButtonCtrl,
					"title":"Отметить всех",
					"onCommand":function(){
						self.setCheck(true);
					}
				}));
				commands.push(new GridCmd(id+":cmd:uncheck",{
					"showCmdControl":true,
					"glyph":"glyphicon glyphicon-unchecked",
					"buttonClass":ButtonCtrl,
					"title":"Отменить отметку у всех",
					"onCommand":function(){
						self.setCheck(false);
					}
				}));
				
			}		
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:recipient_check",{
							"columns":[
								new GridColumn({
									"id":"recipient_check",
									"cellElements":[
										{"elementClass":Control,
										"elementOptions":{
											"tagName":"input",
											"className":"recipientCheck",
											"attrs":{"type":"checkbox"}
										}
										}										
									]
								})
							]
						})
						,new GridCellHead(id+":grid:head:recipient_descr",{
							"value":"Сотрудник",
							"columns":[
								new GridColumn({
									"field":model.getField("recipient_descr")
								})
							]
							,"sortable":true							
						})
						,new GridCellHead(id+":grid:head:department_descr",{
							"value":"Отдел",
							"columns":[
								new GridColumn({
									"field":model.getField("department_descr")
								})
							]
							,"sort":"asc"
							,"sortable":true
						})						
					]
				})
			]
		}),
		"pagination":null,/*new pagClass(id+"_page",
			{"countPerPage":"100"}),		
		*/
		"autoRefresh":true,
		"refreshInterval":5000,
		"rowSelect":false,
		"focus":true,
		"filters":null
	};
	
	ShortMessageRecipientGrid.superclass.constructor.call(this,id,gr_options);
}
//ViewObjectAjx,ViewAjxList
extend(ShortMessageRecipientGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/
ShortMessageRecipientGrid.prototype.setCheck = function(v){
	var recipients = DOMHelper.getElementsByAttr("recipientCheck", this.getNode(), "class", false);
	for (var i=0;i<recipients.length;i++){
		recipients[i].checked = v;
	}
}

ShortMessageRecipientGrid.prototype.openMessageForm = function(rowFields){
	this.m_hideView();
	var recipients = DOMHelper.getElementsByAttr("recipientCheck", this.getNode(), "class", false);
	var recipient_ids = [];
	var recipient_descrs = [];//template
	var ind=0;
	var SHOW_CNT = 10;
	//all count
	var recipients_cnt = 0;
	for (var i=0;i<recipients.length;i++){
		if (recipients[i].checked && DOMHelper.getParentByTagName(recipients[i],"TR")){
			recipients_cnt++;
		}
	}	
	for (var i=0;i<recipients.length;i++){
		if (recipients[i].checked){
			var row = DOMHelper.getParentByTagName(recipients[i],"TR");
			if (row){
				this.getModel().getRow(row.getAttribute("modelindex"));
				recipient_ids.push(this.getModel().getFieldValue("recipients_ref").getKey("id"));
				/* Выводим SHOW_CNT человек и если еще осталось много (всего>SHOW_CNT*2) то выводим слово "еще" и больше никого
				либо выводим всех как есть
				*/
				if (ind==SHOW_CNT && recipients_cnt>=SHOW_CNT*2){
					recipient_descrs.push({
						"recipient":"еще "+(recipients_cnt-10)+"...",
						"ind":ind
					});
				}
				else if (ind>SHOW_CNT && recipients_cnt>=SHOW_CNT*2){
					//nothing
				}
				else{
					recipient_descrs.push({
						"recipient":this.getModel().getFieldValue("recipient_init"),
						"ind":ind
					});
				}
				ind++;
			}
		}
	}
	var multy_rec = recipient_ids.length? true:false;
	if (!multy_rec){
		//one recipient
		recipient_ids.push(rowFields.recipients_ref.getValue().getKey("id"));
		recipient_descrs.push({
			"recipient":rowFields.recipient_init.getValue(),
			"ind":0
		});
	}
	
	var self = this;
	this.m_view = new ShortMessage_View(this.getId()+":form:view",{
		"multyRecipients":multy_rec,
		"recipient_ids":recipient_ids,
		"templateOptions":{
			"recipients":recipient_descrs,
			"multyRecipients":multy_rec,
			"notMultyRecipients":!multy_rec
		},		
		"onClose":function(res){
			if (self.m_view){
				self.m_view.delDOM();
				delete self.m_view;
			}
			if (self.m_form){
				self.m_form.close();
				delete self.m_form;
			}
			if(res&&res.updated){
				window.showNote("Сообщение отправлено");
			}
			else{
				self.m_showView();
			}			
		}
	});
	this.m_form = new WindowFormModalBS(this.getId()+":form",{
		"cmdCancel":false,
		"cmdClose":true,
		"cmdOk":false,
		"content":this.m_view,
		"contentHead":"Новое сообщение"
	});

	this.m_form.open();

}
/* public methods */

