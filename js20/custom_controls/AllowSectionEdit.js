/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends EditString
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function AllowSectionEdit(id,options){
	options = options || {};	
	
	AllowSectionEdit.superclass.constructor.call(this,id,"DIV",options);
}
extend(AllowSectionEdit,Control);

/* Constants */


/* private members */

/* protected*/


/* public methods */

AllowSectionEdit.prototype.getModified = function(){
	var v = this.getValue();
	return ( this.m_valueHash!= (v? CommonHelper.md5(CommonHelper.serialize(v)):0 ) );
}

AllowSectionEdit.prototype.setValue = function(v){
	this.m_value = v;
	this.m_valueHash = v? CommonHelper.md5(CommonHelper.serialize(v)):0;
	this.setTemplateOptions(v);
	this.getNode().innerHTML = this.getTemplateHTML(window.getApp().getTemplate("AllowSectionEdit"),this.getId());		
}

AllowSectionEdit.prototype.getValue = function(){
	var sections = DOMHelper.getElementsByAttr("sections", this.getNode(), "class");
	for(var i=0;i<sections.length;i++){
		if(DOMHelper.hasClass(sections[i],"sections-sub_section")){
			//sub
			var sec_id = sections[i].getAttribute("secId");
			var par = DOMHelper.getParentByTagName(sections[i],"ul");			
			var par_sec = this.m_value.sections[par.getAttribute("parentSecIndex")];
			for(var j=0;j<par_sec.items.length;j++){
				if(par_sec.items[j].fields.id==sec_id){
					par_sec.items[j].fields.checked = sections[i].checked;
					break;
				}
			}
		}
		else{
			//main
			this.m_value.sections[sections[i].getAttribute("secIndex")].fields.checked = sections[i].checked;
		}
	}
	return this.m_value;
}
