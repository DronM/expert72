/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function ReportTemplateFileList_View(id,options){
	options = options || {};	
	
	ReportTemplateFileList_View.superclass.constructor.call(this,id,options);

	var auto_ref = (options.models&&options.models.ReportTemplateFileList_Model)? false:true;
	var model =  !auto_ref? options.models.ReportTemplateFileList_Model : new ReportTemplateFileList_Model();
	var contr = new ReportTemplateFile_Controller();
	
	var constants = {"doc_per_page_count":null};
	window.getApp().getConstantManager().get(constants);
	
	var pagClass = window.getApp().getPaginationClass();
	
	var popup_menu = new PopUpMenu();
	
	this.addElement(new GridAjx(id+":grid",{
		"model":model,
		"keyIds":["id"],
		"controller":contr,
		"editInline":false,
		"editWinClass":ReportTemplateFile_Form,
		"popUpMenu":popup_menu,
		"commands":new GridCmdContainerAjx(id+":grid:cmd",{
			"addCustomCommands":function(commands){
				commands.push(new ReportTemplateFileApplyCmd(id+":cmd:apply"));
			}		
		}),
		"head":new GridHead(id+":grid:head",{
			"elements":[
				new GridRow(id+":grid:head:row0",{
					"elements":[
						new GridCellHead(id+":grid:head:report_templates_name",{
							"value":"Наименование",
							"columns":[								
								new GridColumn({"field":model.getField("report_templates_name")})
							],
							"sortable":true,
							"sort":"asc"
						})
						,new GridCellHead(id+":grid:head:file_name",{
							"value":"Файл шаблона",
							"columns":[								
								new GridColumn({"field":model.getField("file_name")})
							],
							"sortable":true
						})						
						,new GridCellHead(id+":grid:head:employees_ref",{
							"value":"Автор",
							"columns":[								
								new GridColumnRef({"field":model.getField("employees_ref")})
							],
							"sortable":true
						})						
					]
				})
			]
		}),
		"pagination":new pagClass(id+"_page",
			{"countPerPage":constants.doc_per_page_count.getValue()}),		
		
		"autoRefresh":auto_ref,
		"refreshInterval":0,
		"rowSelect":false,
		"focus":true
	}));		
}
extend(ReportTemplateFileList_View,ViewAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

