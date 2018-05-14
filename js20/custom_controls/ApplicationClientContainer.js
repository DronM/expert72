/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {object} options.elementClass
 */
function ApplicationClientContainer(id,options){
	options = options || {};	
	
	this.m_elementClass = options.elementClass;
	this.m_elementOptions = options.elementOptions;
	
	this.m_mainView = options.elementOptions.mainView;
	
	options.template = window.getApp().getTemplate("ApplicationClientContainer");
	
	var self = this;
	options.addElement = function(){
		this.m_container = new ControlContainer(id+":container","DIV");
		this.addElement(this.m_container);
		this.addElement(new ButtonCmd(this.getId()+":cmdAdd",{
			"title":"Добавить нового исполнителя",
			"caption":"Добавить исполнителя",
			"onClick":function(){
				var new_elem = self.createNewElement();
				self.m_container.addElement(new_elem);
				new_elem.toDOM(self.m_container.getNode());
				self.addPanelEvents();
				self.m_mainView.calcFillPercent();
			}
		}));	
	}
	
	ApplicationClientContainer.superclass.constructor.call(this,id,options.tagName,options);
	
	if (options.valueJSON){
		this.setValue(options.valueJSON);
	}
}
extend(ApplicationClientContainer,ControlContainer);

/* Constants */


/* private members */

/* protected*/
ApplicationClientContainer.prototype.m_container;
ApplicationClientContainer.prototype.m_elementClass;
ApplicationClientContainer.prototype.m_elementOptions;

/* public methods */
ApplicationClientContainer.prototype.getValue = function(){	
	return CommonHelper.serialize(this.getValueJSON());
}

ApplicationClientContainer.prototype.getValueJSON = function(){	
	var o_ar = [];
	var elements = this.m_container.getElements();
	for (var id in elements){
		o_ar.push(elements[id].getValueJSON());
	}
	return o_ar;
}

ApplicationClientContainer.prototype.createNewElement = function(){
	var opts = (this.m_elementOptions)? CommonHelper.clone(this.m_elementOptions):{};
	var ind = this.m_container.getCount();
	var id = this.getId()+":container:"+ind;
	opts.cmdClose = true;
	self = this;	
	opts.onCloseContractor = function(){
		self.m_container.delElement(this.getName());
		this.delDOM();
		self.m_mainView.calcFillPercent();
	}
	opts.templateOptions = {
		"IND":(ind+1)
	};
	var new_elem = new this.m_elementClass(id,opts);
	
	return new_elem;	
}

ApplicationClientContainer.prototype.setValueOrInit = function(v,isInit){
	this.m_container.clear();
	
	var o_ar;
	if (typeof(v)=="string"){
		o_ar = CommonHelper.unserialize(v);
	}
	else{
		o_ar = v;
	}
	for (var i=0;i<o_ar.length;i++){
		var new_elem = this.createNewElement();
		if (isInit && new_elem.setInitValue){
			new_elem.setInitValue(o_ar[i]);
		}
		else{
			new_elem.setValue(o_ar[i]);
		}
		this.m_container.addElement(new_elem);
		new_elem.toDOM(this.m_container.getNode());
	}
	this.addPanelEvents();	
}

ApplicationClientContainer.prototype.setValue = function(v){
	this.setValueOrInit(v,false);
}

ApplicationClientContainer.prototype.setInitValue = function(v){
	this.setValueOrInit(v,true);
}

ApplicationClientContainer.prototype.setValid = function(){
	var elements = this.m_container.getElements();
	for (var id in elements){
		elements[id].setValid();
	}
}

EditJSON.prototype.setNotValid = function(str){
	//var list = this.getElements();
	//console.log("Error:"+str)
}

ApplicationClientContainer.prototype.getModified = function(){
	var res = false;
	var elements = this.m_container.getElements();
	for (var id in elements){
		if (elements[id].getModified()){
			res = true;
			break;
		}
	}
	return res;
}

ApplicationClientContainer.prototype.isNull = function(){
	var res = true;
	var elements = this.m_container.getElements();
	for (var id in elements){
		if (!elements[id].isNull()){
			res = false;
			break;
		}
	}
	return res;
}

ApplicationClientContainer.prototype.getFillPercent = function(){
	var tot=0,cnt=0;
	var elements = this.m_container.getElements();
	for (var contractor_id in elements){
		if (elements[contractor_id] && elements[contractor_id].getFillPercent){				
			tot+= elements[contractor_id].getFillPercent();
			cnt++;
			
		}
	}
	
	return (cnt)? Math.floor(tot/cnt):0;
}

ApplicationClientContainer.prototype.addPanelEvents = function(){	
	// Collapse on click
	   $('.panel [data-action=collapse]').click(function (e) {
		e.preventDefault();
		var $panelCollapse = $(this).parent().parent().parent().parent().nextAll();
		$(this).parents('.panel').toggleClass('panel-collapsed');
		$(this).toggleClass('rotate-180');

		//containerHeight(); // recalculate page height
		var availableHeight = $(window).height() - $('.page-container').offset().top - $('.navbar-fixed-bottom').outerHeight();

		$('.page-container').attr('style', 'min-height:' + availableHeight + 'px');
		$panelCollapse.slideToggle(150);
	    });
}
/*
ApplicationClientContainer.prototype.setEnabled = function(v){
console.log("ApplicationClientContainer.prototype.setEnabled")
	for (var elem_id in this.m_elements){
		this.m_elements[elem_id].setEnabled(v);
	}		
	if (this.m_container){
		for (var elem_id in this.m_container.m_elements){
			this.m_container.m_elements[elem_id].setEnabled(v);
		}		
	}	
	ApplicationClientContainer.superclass.setEnabled.call(this,v);
}
*/
