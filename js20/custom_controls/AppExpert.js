/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {namespace} options
 */	
function AppExpert(options){
	options = options || {};
	
	options.lang = "rus";	
	options.paginationClass = Pagination;
	
	AppExpert.superclass.constructor.call(this,"CRM",options);
}
extend(AppExpert,App);

/* Constants */
AppExpert.prototype.COLOR_CLASS = "bg-teal-400";

/* private members */
AppExpert.prototype.m_colorClass;

/* protected*/

AppExpert.prototype.makeItemCurrent = function(elem){
	if (elem){
		var l = DOMHelper.getElementsByAttr("active", document.body, "class", true,"LI");
		for(var i=0;i<l.length;i++){
			DOMHelper.delClass(l[i],"active");
		}
		DOMHelper.addClass(elem.parentNode,"active");
		if (elem.nextSibling){
			elem.nextSibling.style="display: block;";
		}
	}
}

AppExpert.prototype.showMenuItem = function(item,c,f,t,extra){
	AppExpert.superclass.showMenuItem.call(this,c,f,t,extra);
	this.makeItemCurrent(item);
}


/* public methods */
AppExpert.prototype.formatError = function(erCode,erStr){
	return (erStr +( (erCode)? (", код:"+erCode):"" ) );
}

AppExpert.prototype.getColorClass = function(){
	return this.m_colorClass;
}
AppExpert.prototype.setColorClass = function(v){
	this.m_colorClass = v;
}

