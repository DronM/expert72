/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @extends ViewObjectAjx.js
 * @requires core/extend.js  
 * @requires controls/ViewObjectAjx.js 
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {object} options
 * @param {object} options.models All data models
 * @param {object} options.variantStorage {name,model}
 */	
function DocFlowTypeDialog_View(id,options){	

	options = options || {};
	
	options.controller = new DocFlowType_Controller();
	options.model = options.models.DocFlowTypeDialog_Model;
	
	options.addElement = function(){
		this.addElement(new EditString(id+":name",{
			"labelCaption":this.FIELD_CAP_name
		}));	
		this.addElement(new EditString(id+":num_prefix",{
			"labelCaption":this.FIELD_CAP_num_prefix
		}));	
		this.addElement(new EditInterval(id+":def_interval",{
			"labelCaption":this.FIELD_CAP_def_interval,
			"editMask":"99:99:99"
		}));	

		this.addElement(new Enum_doc_flow_type_types(id+":doc_flow_type_types",{
			"labelCaption":this.FIELD_CAP_doc_flow_type_types
		}));	
		
		this.addElement(new ConclusionDictionaryDetailEdit(id+":document_types_ref",{
			"labelCaption":"Вид документа по классификатору:"
			,"conclusion_dictionary_name":"tDocumentType"
		}));	
		
	}
	
	DocFlowTypeDialog_View.superclass.constructor.call(this,id,options);
		
	//****************************************************
	//read
	this.setDataBindings([
		new DataBinding({"control":this.getElement("name")})
		,new DataBinding({"control":this.getElement("num_prefix")})
		,new DataBinding({"control":this.getElement("def_interval")})
		,new DataBinding({"control":this.getElement("doc_flow_type_types"),"field":options.model.getField("doc_flow_types_type_id")})
		,new DataBinding({"control":this.getElement("document_types_ref"),"field":options.model.getField("document_type")})
	]);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name"),"fieldId":"name"})
		,new CommandBinding({"control":this.getElement("num_prefix"),"fieldId":"num_prefix"})
		,new CommandBinding({"control":this.getElement("def_interval")})
		,new CommandBinding({"control":this.getElement("doc_flow_type_types"),"fieldId":"doc_flow_types_type_id"})
		,new CommandBinding({"control":this.getElement("document_types_ref"),"fieldId":"document_type"})
	]);
		
}
extend(DocFlowTypeDialog_View,ViewObjectAjx);
