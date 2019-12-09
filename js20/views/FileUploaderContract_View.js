/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends FileUploaderApplication_View
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function FileUploaderContract_View(id,options){
	options = options || {};	
	
	options.readOnly = true;
	options.allowFileDeletion = false;
	options.allowFileDownload = true;
	
	options.setFileOptions = this.setFileOptions;
	
	FileUploaderContract_View.superclass.constructor.call(this,id,options);
}
extend(FileUploaderContract_View, FileUploaderApplication_View);

/* Constants */


/* private members */

/* protected*/

/* public methods */
FileUploaderContract_View.prototype.checkRequiredFiles = function(){
	//NO required documents
}

FileUploaderContract_View.prototype.deleteFileFromServer = function(fileId,itemId){
}

FileUploaderContract_View.prototype.getQuerySruc = function(file){
}

FileUploaderContract_View.prototype.setFileOptions = function(fileOpts,file){
	FileUploaderContract_View.superclass.setFileOptions.call(this,fileOpts,file);
	
	if(file.doc_flow_out && !file.deleted){
		fileOpts.refTitle = fileOpts.refTitle +( (file.is_switched=="t")? " (добавлен взамен другого файла)":" (добавлен без замены)" );
		fileOpts.refClass = fileOpts.refClass +( (file.is_switched=="t")? " uploadedByThisSwitched":" uploadedByThisAdded" );
	}
	
}
