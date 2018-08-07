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
		,"doc_flow_inside":{
			"dataTypeDescrLoc":"Внутренний документ",
			"ctrlClass":DocFlowInsideEditRef,
			"ctrlOptions":{"keyIds":["id"]},
			"dialogClass":DocFlowInsideDialog_Form
		}		
		,"applications":{
			"dataTypeDescrLoc":"Заявление",
			"ctrlClass":ApplicationEditRef,
			"ctrlOptions":{"keyIds":["id"]},
			"dialogClass":ApplicationDialog_Form
		}
		,"contracts":{
			"dataTypeDescrLoc":"Контракт",
			"ctrlClass":ContractEditRef,
			"ctrlOptions":{"keyIds":["id"]},
			"dialogClass":ContractDialog_Form
		}
		,"short_messages":{
			"dataTypeDescrLoc":"Сообщение чата",
			"ctrlClass":null,
			"ctrlOptions":{"keyIds":["id"]},
			"dialogClass":ShortMessage_Form
		
		}
	});
		
	AppExpert.superclass.constructor.call(this,"Expert72",options);
	
	if (this.storageGet(this.getSidebarId())=="xs"){
		$('body').toggleClass('sidebar-xs');
	}
	
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
AppExpert.prototype.getSidebarId = function(){
	return this.getServVar("user_name")+"_"+"sidebar-xs";
}
AppExpert.prototype.toggleSidebar = function(){
	var id = this.getSidebarId();
	this.storageSet(id,(this.storageGet(id)=="xs")? "":"xs");
}

AppExpert.prototype.formatError = function(erCode,erStr){
	return (erStr +( (erCode)? (", код:"+erCode):"" ) );
}

AppExpert.prototype.getColorClass = function(){
	return this.m_colorClass;
}
AppExpert.prototype.setColorClass = function(v){
	this.m_colorClass = v;
}

AppExpert.prototype.magnify = function(dir){
	this.currFFZoom = this.currFFZoom? this.currFFZoom : 1;
	this.currIEZoom = this.currIEZoom? this.currIEZoom : 100;
	
	if (dir){
		    var step = 0.02;
		    this.currFFZoom += step; 
		    $('body').css('MozTransform','scale(' + this.currFFZoom + ')');
		/*	
		if ($.browser.mozilla){
		    var step = 0.02;
		    currFFZoom += step; 
		    $('body').css('MozTransform','scale(' + currFFZoom + ')');
		} else {
		    var step = 2;
		    currIEZoom += step;
		    $('body').css('zoom', ' ' + currIEZoom + '%');
		}
		*/
	}
	else{
		    var step = 0.02;
		    this.currFFZoom -= step;                 
		    $('body').css('MozTransform','scale(' + this.currFFZoom + ')');
	
		/*
		if ($.browser.mozilla){
		    var step = 0.02;
		    currFFZoom -= step;                 
		    $('body').css('MozTransform','scale(' + currFFZoom + ')');

		} else {
		    var step = 2;
		    currIEZoom -= step;
		    $('body').css('zoom', ' ' + currIEZoom + '%');
		}
		*/	
	}
}
