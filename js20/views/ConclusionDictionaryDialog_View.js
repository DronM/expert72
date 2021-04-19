/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ViewObjectAjx
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function ConclusionDictionaryDialog_View(id,options){	

	options = options || {};
	
	options.HEAD_TITLE = "Классификатор заключения"
	
	options.model = options.models.ConclusionDictionary_Model;
	options.controller = options.controller || new ConclusionDictionary_Controller();
	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new EditString(id+":name",{			
			"labelCaption":"Идентификатор:",
			"required":true,
			"length":"50"
		}));	
	
		this.addElement(new EditString(id+":descr",{
			"labelCaption":"Наименование:",
			"required":true,
			"focus":true,
			"length":"500"
		}));	

		//details
		this.addElement(new ConclusionDictionaryDetailList_View(id+":detail_list",{
			"detail":true
		}));			

	}
	
	ConclusionDictionaryDialog_View.superclass.constructor.call(this,id,options);
	
	
	//****************************************************	
	
	//read
	var read_b = [
		new DataBinding({"control":this.getElement("name")}),
		new DataBinding({"control":this.getElement("descr")}),
	];
	this.setDataBindings(read_b);
	
	//write
	var write_b = [
		new CommandBinding({"control":this.getElement("name")}),
		new CommandBinding({"control":this.getElement("descr")}),
	];
	this.setWriteBindings(write_b);
	
	this.addDetailDataSet({
		"control":this.getElement("detail_list").getElement("grid"),
		"controlFieldId":"conclusion_dictionary_name",
		"value":options.model.getFieldValue("name")
	});
	
}
extend(ConclusionDictionaryDialog_View,ViewObjectAjx);


