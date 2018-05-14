/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function ConstructionTypeDialog_View(id,options){	

	options = options || {};
	
	options.model = options.model || options.models.ConstructionType_Model;
	options.controller = options.controller || new ConstructionType_Controller();
	
	ConstructionTypeDialog_View.superclass.constructor.call(this,id,options);
	
	var self = this;
		
	this.addElement(new EditString(id+":name",{"maxLength":"200","required":true}));	

	//********* features grid ***********************
	var model = new TechnicalFeature_Model();
	
	this.addElement(new GridAjx(id+":technical_features",{
		"model":model,
		"keyIds":["name"],
		"controller":new TechnicalFeature_Controller({"clientModel":model}),
		"editInline":true,
		"editWinClass":null,
		"popUpMenu":new PopUpMenu(),
		"commands":new GridCmdContainerAjx(id+":technical_features:cmd",{
			"cmdSearch":false,
			"cmdExport":false
		}),
		"head":new GridHead(id+":technical_features:head",{
			"elements":[
				new GridRow(id+":technical_features:head:row0",{
					"elements":[
						new GridCellHead(id+":technical_features:head:name",{
							"value":"Наименование",
							"columns":[
								new GridColumn({
									"field":model.getField("name")})
							]
						}),					
						new GridCellHead(id+":technical_features:head:value",{
							"value":"Значение",
							"columns":[
								new GridColumn({
									"field":model.getField("value")})							
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
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("name")}),
		new DataBinding({"control":this.getElement("technical_features"),"fieldId":"technical_features"})
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [
			new CommandBinding({"control":this.getElement("name")}),
			new CommandBinding({"control":this.getElement("technical_features"),"fieldId":"technical_features"})
	];
	this.setWriteBindings(write_b);
	
}
extend(ConstructionTypeDialog_View,ViewObjectAjx);
