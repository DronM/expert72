/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 * @param {namespace} options.models All data models
 * @param {namespace} options.variantStorage {name,model}
 */	
function About_View(id,options){
	options = options || {};	
	
	this.m_model = options.models.About_Model;
	this.m_model.getRow(0);

	this.APP_NAME = this.m_model.getFieldValue("app_name");
	this.APP_VERSION = this.m_model.getFieldValue("app_version");
	this.APP_AUTHOR = this.m_model.getFieldValue("author");
	this.TECH_MAIL = this.m_model.getFieldValue("tech_mail");
	this.DB_NAME = this.m_model.getFieldValue("db_name");
	this.FW_VERSION = this.m_model.getFieldValue("fw_version");				

	About_View.superclass.constructor.call(this,id,options);
}
extend(About_View,ViewAjx);

/* Constants */


/* private members */
About_View.prototype.m_model;

/* protected*/


/* public methods */
