/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends 
 * @requires core/extend.js
 * @requires controls/.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Manual_View(id,options){
	options = options || {};
	
	options.model = options.models.Manual_Model;
	options.controller = options.controller || new Manual_Controller();
	
	var self = this;
	
	options.addElement = function(){
		//********* roles grid ***********************
		var model = new RoleTypeList_Model();
	
		this.addElement(new GridAjx(id+":roles",{
			"model":model,
			"keyIds":["id"],
			"controller":new RoleType_Controller({"clientModel":model}),
			"editInline":true,
			"editWinClass":null,
			"popUpMenu":new PopUpMenu(),
			"commands":new GridCmdContainerAjx(id+":roles:cmd",{
				"cmdSearch":false,
				"cmdExport":false
			}),
			"head":new GridHead(id+":roles:head",{
				"elements":[
					new GridRow(id+":roles:head:row0",{
						"elements":[
							new GridCellHead(id+":roles:head:role_type",{
								"value":"Роль",
								"columns":[
									new EnumGridColumn_role_types({
										"field":model.getField("role_type"),
										"ctrlClass":Enum_role_types
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
			"rowSelect":true,
			"focus":true		
		}));
		
		//********* content grid ***********************
		var model = new ManualContent_Model();
	
		this.addElement(new GridAjx(id+":content",{
			"model":model,
			"keyIds":["id"],
			"controller":new ManualContent_Controller({"clientModel":model}),
			"editInline":true,
			"editWinClass":null,
			"popUpMenu":new PopUpMenu(),
			"commands":new GridCmdContainerAjx(id+":content:cmd",{
				"cmdSearch":false,
				"cmdExport":false
			}),
			"head":new GridHead(id+":content:head",{
				"elements":[
					new GridRow(id+":content:head:row0",{
						"elements":[
							new GridCellHead(id+":content:head:descr",{
								"value":"Описание",
								"columns":[
									new GridColumn({
										"field":model.getField("descr"),
										"ctrlClass":EditString,
										"ctrlOptions":{
											"maxLength":250
										}
									})
								]
							})	
							,new GridCellHead(id+":content:head:url",{
								"value":"Ссылка",
								"columns":[
									new GridColumn({
										"field":model.getField("url"),
										"ctrlClass":EditString,
										"ctrlOptions":{
											"maxLength":250
										}
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
			"rowSelect":true,
			"focus":true		
		}));
		
	}
	
	EmailTemplate_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("roles"),"fieldId":"roles"})
		,new DataBinding({"control":this.getElement("content"),"fieldId":"content"})
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [
		new CommandBinding({"control":this.getElement("roles"),"fieldId":"roles"})
		,new CommandBinding({"control":this.getElement("content"),"fieldId":"content"})
	];
	this.setWriteBindings(write_b);
}
//ViewObjectAjx,ViewAjxList
extend(Manual_View,ViewObjectAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

