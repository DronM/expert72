/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends TreeAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function ApplicationTemplateContentTree(id,options){
	
	options = options || {};
	
	this.m_mainView = options.mainView;
	
	var content_model = new ApplicationTemplateContent_Model({
			"sequences":{"id":0},
			"primaryKeyIndex":true
	});
	
	var self = this;
	var cmd_list = {};
	if (options.cmdCopyFromMain){
		cmd_list.addElement = function(){
			this.addElement(new ButtonCmd(this.getId()+":cmdCopyFromMain",{
				"caption":"Скопировать из основного дерева",
				"onClick":function(){
					self.m_mainView.getElement("content_for_experts").setValue(self.m_mainView.getElement("content").getValue());
				}
			}));
		}
	}
	
	
	CommonHelper.merge(options,{
		"keyIds":["id"],		
		"labelCaption":"Шаблон:",
		"model":content_model,
		"className":"menuConstructor",
		"controller":new ApplicationTemplateContent_Controller({
			"clientModel":content_model			
		}),
		"commands":new GridCmdContainerAjx(id+":grid:cmd",cmd_list),
		"rootCaption":"РАЗДЕЛЫ",
		"head":new GridHead(id+":head",{
			"rowOptions":[{"tagName":"LI"}],
			"elements":[
				new GridRow(id+":content-tree:head:row0",{
					"elements":[
						new GridCellHead(id+":content-tree:head:row0:descr",{
							"columns":[
								new GridColumn({
									"field":content_model.getField("descr"),
									"model":content_model,
									"cellOptions":{
										"tagName":"SPAN"									
									}
								}),
								new GridColumnBool({
									"field":content_model.getField("required"),
									"model":content_model,
									"cellOptions":{
										"tagName":"SPAN"									
									},
									"ctrlOptions":{									
										"labelCaption":"Обязательно наличие файлов:",
										"contTagName":"DIV",
										"ctrlClass":EditCheckBox,
										"labelClassName":"control-label "+window.getBsCol(2),
										"editContClassName":"input-group "+window.getBsCol(1)
									}
								}),
								
							]
						})
					]
				})
			]
		})		
	});	
	
	ApplicationTemplateContentTree.superclass.constructor.call(this,id,options);
}
extend(ApplicationTemplateContentTree,TreeAjx);

/* Constants */


/* private members */

/* protected*/


/* public methods */

