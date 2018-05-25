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
	
	this.setColorClass(options.servVars.color_palette || this.COLOR_CLASS);
	
	this.setDataTypes({
		"doc_flow_registrations":{"dialogClass":DocFlowRegistration_Form}
		,"doc_flow_examinations":{"dialogClass":DocFlowExamination_Form}
		,"doc_flow_approvements":{"dialogClass":DocFlowApprovement_Form}		
		,"departments":{
			"dataTypeDescrLoc":"Отдел",
			"ctrlClass":DepartmentSelect,
			"ctrlOptions":{"keyIds":["id"]}
		}
		,"employees":{
			"dataTypeDescrLoc":"Сотрудник",
			"ctrlClass":EmployeeEditRef,
			"ctrlOptions":{"keyIds":["id"]}
		}
		,"doc_flow_out":{
			"dataTypeDescrLoc":"Исходящий документ",
			"ctrlClass":DocFlowOutEditRef,
			"ctrlOptions":{"keyIds":["id"]},
			"dialogClass":DocFlowOutDialog_Form
		}
		,"doc_flow_in":{
			"dataTypeDescrLoc":"Входяший документ",
			"ctrlClass":DocFlowInEditRef,
			"ctrlOptions":{"keyIds":["id"]},
			"dialogClass":DocFlowInDialog_Form
		}
		,"applications":{
			"dataTypeDescrLoc":"Заявление",
			"ctrlClass":ApplicationEditRef,
			"ctrlOptions":{"keyIds":["id"]},
			"dialogClass":ApplicationDialog_Form
		}
		
	});
	
	AppExpert.superclass.constructor.call(this,"Expert72",options);
}
extend(AppExpert,App);

/* Constants */

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
