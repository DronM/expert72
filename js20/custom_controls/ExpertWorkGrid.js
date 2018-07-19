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
function ExpertWorkGrid(id,options){
	options = options || {};	
	
	var model = new ExpertWorkList_Model();
	var contr = new ExpertWork_Controller();
	
	var popup_menu = new PopUpMenu();
	
	var self = this;
	
	CommonHelper.merge(options,{
		"contClassName":"sectionGrid",
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			//"cmdInsert":false,
			//"cmdCopy":false,
			//"cmdDelete":false
			"cmdSearch":false
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:date_time",{
							"value":"Дата",
							"columns":[
								new GridColumnDateTime({
									"field":model.getField("date_time"),
									"dateFormat":"d/m/Y H:i",
									"ctrlClass":EditDateTime,
									"ctrlOptions":{
										"cmdClear":false,
										"editMask":"99/99/9999 99:99",
										"dateFormat":"d/m/Y H:i",
										"enabled":(window.getApp().getServVar("role_id")=="admin"),
										"value":DateHelper.time()
									}
								})
							],
							"sortable":true,
							"sort":"desc"
						})
						,new GridCellHead(id+":grid:head:experts_ref",{
							"value":"Эксперт",
							"columns":[
								new GridColumnRef({
									"field":model.getField("experts_ref"),
									"ctrlClass":EmployeeEditRef,
									"ctrlBindFieldId":"expert_id",
									"ctrlOptions":{
										"cmdOpen":false,
										"cmdClear":false,
										"labelCaption":"",
										"value":CommonHelper.unserialize(window.getApp().getServVar("employees_ref")),
										"enabled":(window.getApp().getServVar("role_id")=="admin"),
										"keyIds":["expert_id"]										
									}
								})
							],
							"sortable":true
						})
						,new GridCellHead(id+":grid:head:comment_text",{
							"value":"Комментарий",
							"columns":[
								new GridColumn({
									"field":model.getField("comment_text"),
									"ctrlClass":EditText,
									"ctrlOptions":{
										"attrs":{"autofocus":"autofocus"}
									}
								})
							]
						})					
						,new GridCellHead(id+":grid:head:files",{
							"value":"Файлы",
							"columns":[
								new GridColumn({
									"field":model.getField("files"),
									"ctrlClass":EditFile,
									"ctrlBindFieldId":"file_data",
									"ctrlOptions":{
										"multipleFiles":true,
										"onDownload":function(fileId){
											self.onDownload(fileId);
										},
										"onDeleteFile":function(fileId,callBack){
											self.onDeleteFile(fileId,callBack);
										}
										
									}
								})
							]
						})					
						
					]
				})
			]
		}),
		"pagination":null,/*new pagClass(id+"_page",
			{"countPerPage":"100"}),		
		*/
		"autoRefresh":true,
		"refreshInterval":null,//constants.grid_refresh_interval.getValue()*1000,
		"rowSelect":false,
		"focus":true,
		"filters":[
			{"field":"contract_id",
			"sign":"e",
			"val":options.contract_id
			}
			,{"field":"section_id",
			"sign":"e",
			"val":options.section_id
			}
		]
	});
	
	this.m_contractId = options.contract_id;
	this.m_sectionId = options.section_id;
	
	ExpertWorkGrid.superclass.constructor.call(this,id,options);
	
	this.m_origCreateNewCell = this.createNewCell;
	
	this.createNewCell = function(column,row){
		if(column.getId()=="files"){
			var cell_class = column.getCellClass();			
			var elements = [];
			var files = column.getField().getValue();
			if(files){
				var self = this;
				for(var i=0;i<files.length;i++){
					elements.push(
						new ControlContainer(null,"P",{
							"elements":[
								new Control(null,"A",{
									"value":files[i].name+"("+CommonHelper.byteFormat(files[i].size,2)+")",
									"attrs":{
										"href":"#",
										"file_id":files[i].id,
										"expert_id":this.getModel().getFieldValue("experts_ref").getKey("id")
									},
									"title":"Добавлен "+DateHelper.format(DateHelper.strtotime(files[i].date),"d/m/y"),
									"events":{
										"click":function(e){
											if (e.preventDefault){
												e.preventDefault();
											}
											e.stopPropagation();
											self.downloadFile(this.getAttr("expert_id"),this.getAttr("file_id"));
										}
									}
								})
							]
						})
					);
				}
			}
			return (new cell_class(row.getId()+":"+column.getId(),{
				"elements":elements
			}));
		}
		else{
			return this.m_origCreateNewCell(column,row);
		}		
	};
	
	var pm = contr.getPublicMethod("insert");
	pm.setFieldValue("contract_id",options.contract_id);
	pm.setFieldValue("section_id",options.section_id);

	var pm = contr.getPublicMethod("update");
	pm.setFieldValue("contract_id",options.contract_id);
	pm.setFieldValue("section_id",options.section_id);
	
}
extend(ExpertWorkGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

ExpertWorkGrid.prototype.onDownload = function(fileId){	
	var f = this.getModel().getField("experts_ref");
	if (f.isSet()){
		this.downloadFile(f.getValue().getKey("id"),fileId);
	}
}

ExpertWorkGrid.prototype.downloadFile = function(expertId,fileId){
	var pm = this.getReadPublicMethod().getController().getPublicMethod("download_file");
	pm.setFieldValue("contract_id",this.m_contractId);
	pm.setFieldValue("section_id",this.m_sectionId);
	pm.setFieldValue("expert_id",expertId);
	pm.setFieldValue("file_id",fileId);
	pm.download();
}


ExpertWorkGrid.prototype.onDeleteFile = function(fileId,callBack){
	var f = this.getModel().getField("experts_ref");
	if (f.isSet()){
		var self =this;
		WindowQuestion.show({"text":"Удалить загруженный файл?","no":false,"callBack":function(res){
			if (res==WindowQuestion.RES_YES){
				var pm = self.getReadPublicMethod().getController().getPublicMethod("delete_file");
				pm.setFieldValue("contract_id",self.m_contractId);
				pm.setFieldValue("section_id",self.m_sectionId);
				pm.setFieldValue("expert_id",f.getValue().getKey("id"));
				pm.setFieldValue("file_id",fileId);
				pm.run({
					"ok":callBack
				});
			}	
		}});
	}	
}

