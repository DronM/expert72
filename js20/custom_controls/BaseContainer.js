/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends BaseContainer
 * @requires core/extend.js
 * @requires BaseContainer.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function BaseContainer(id,options){
	options = options || {};	
	
	this.m_elementClass = options.elementClass;
	this.m_elementOptions = options.elementOptions;
	
	this.m_mainView = options.elementOptions.mainView;
	
	this.m_readOnly = options.readOnly;

	options.template.templateOptions = {"readOnly":options.readOnly};
	
	BaseContainer.superclass.constructor.call(this,id,options.tagName,options);
	
	if (options.valueJSON){
		this.setValue(options.valueJSON);
	}
}
//ViewObjectAjx,ViewAjxList
extend(BaseContainer,ControlContainer);

/* Constants */


/* private members */

/* protected*/
BaseContainer.prototype.m_container;
BaseContainer.prototype.m_elementClass;
BaseContainer.prototype.m_elementOptions;

/* public methods */
BaseContainer.prototype.getValue = function(){	
	return CommonHelper.serialize(this.getValueJSON());
}

BaseContainer.prototype.getValueJSON = function(){	
	var o_ar = [];
	var elements = this.m_container.getElements();
	for (var id in elements){
		o_ar.push(elements[id].getValueJSON());
	}
	return o_ar;
}

BaseContainer.prototype.createNewElement = function(){
	var opts = (this.m_elementOptions)? CommonHelper.clone(this.m_elementOptions):{};
	var ind = this.m_container.getCount();
	var id = this.getId()+":container:"+ind;
	opts.cmdClose = true;
	opts.attrs = opts.attrs||{};
	opts.attrs.ind=ind;
	
	self = this;	
	opts.onClosePanel = function(e){
		self.m_container.delElement(this.getAttr("ind"));
		this.delDOM();
		self.m_mainView.calcFillPercent();
	}
	opts.templateOptions = {
		"IND":(ind+1),
		"panelClass":"panel  panel-"+((ind%2==0)? "even":"odd"),
		"cmdClose":!this.m_readOnly
	};
	var new_elem = new this.m_elementClass(id,opts);
	
	return new_elem;	
}

BaseContainer.prototype.setValueOrInit = function(v,isInit){
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

BaseContainer.prototype.setValue = function(v){
	this.setValueOrInit(v,false);
}

BaseContainer.prototype.setInitValue = function(v){
	this.setValueOrInit(v,true);
}

BaseContainer.prototype.setValid = function(){
	var elements = this.m_container.getElements();
	for (var id in elements){
		elements[id].setValid();
	}
}

BaseContainer.prototype.setNotValid = function(str){
	//var list = this.getElements();
	//console.log("Error:"+str)
}

BaseContainer.prototype.getModified = function(){
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

BaseContainer.prototype.isNull = function(){
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

BaseContainer.prototype.getFillPercent = function(){
	var tot=0,cnt=0;
	var elements = this.m_container.getElements();
	for (var o_id in elements){
		if (elements[o_id] && elements[o_id].getFillPercent){				
			tot+= elements[o_id].getFillPercent();
			cnt++;
			
		}
	}
	
	return (cnt)? Math.floor(tot/cnt):0;
}

BaseContainer.prototype.addPanelEvents = function(){	
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

