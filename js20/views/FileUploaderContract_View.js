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
	options.allowFileDownload = false;
	
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
