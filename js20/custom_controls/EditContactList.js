/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditModalDialog
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function EditContactList(id,options){
	options = options || {};	

	options.viewClass = ViewContact;
	//options.viewTemplate = "EditContact";
	options.headTitle = "Контакты";
	options.labelCaption = "Контакты:";
	
	EditContactList.superclass.constructor.call(this,id,options);
}
extend(EditContactList,EditModalDialog);

/* Constants */
EditContactList.prototype.CONTACT_CNT = 1;

/* private members */

/* protected*/


/* public methods */
EditContactList.prototype.formatValue = function(val){
	var res = "";
	if (this.m_valueJSON && this.m_valueJSON.contacts){
		var model = new ContactName_Model({"fields":["name"],"data":CommonHelper.unserialize(this.m_valueJSON.contacts)});
		var cnt = 0;
		while(model.getNextRow()){
			res+= (res=="")? "":", ";
			res+= model.getFieldValue("name");
			cnt++;
			if (cnt==this.CONTACT_CNT){
				var rest = model.getRowCount()-cnt;
				if (rest){
					res+=", еще "+rest+"...";
				}
				break;
			}
		}
	}
	return res;	
}
