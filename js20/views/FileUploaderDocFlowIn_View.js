/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends FileUploaderDocFlowOut_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function FileUploaderDocFlowIn_View(id,options){
	options = options || {};	
	
	FileUploaderDocFlowIn_View.superclass.constructor.call(this, id,options);
}
extend(FileUploaderDocFlowIn_View,FileUploaderDocFlowOut_View);

/* Constants */


/* private members */

/* protected*/


/* public methods */
FileUploaderDocFlowIn_View.prototype.getQuerySruc = function(file){
	return {
		"f":"doc_flow_file_upload",
		"file_id":file.file_id,
		"doc_flow_id":this.m_mainView.getElement("id").getValue(),
		"doc_type":"in"
	};
}

