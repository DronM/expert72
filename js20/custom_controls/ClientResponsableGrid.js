/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ClientResponsableGrid(id,options){
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
	ClientResponsableGrid.superclass.constructor.call(this,id,options);
}
extend(ClientResponsableGrid,GridAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

