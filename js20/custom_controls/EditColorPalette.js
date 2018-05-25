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
function EditColorPalette(id,options){
	options = options || {};	

	var self = this;
	options.buttonSelect = new ButtonCtrl(id+":btnSel",{
		"glyph":"glyphicon-menu-hamburger",
		"onClick":function(e){
			self.selectColor(this.getEditControl());
		}
	});
	
	EditColorPalette.superclass.constructor.call(this,id,options);
}
extend(EditColorPalette,EditString);

/* Constants */


/* private members */

/* protected*/


/* public methods */
EditColorPalette.prototype.selectColor = function(editCtrl){
	var self = this;
	this.m_view = new View(this.getId()+":view:body:view",{
		"template":window.getApp().getTemplate("ColorPaletteList"),
		"events":{
			"click":function(e){
				if (e.target.tagName.toUpperCase()=="DIV"){
					var color = e.target.attributes.color_palette.value;
					editCtrl.setValue(color);
					self.closeSelect();
					var old_color = window.getApp().getColorClass();
					window.getApp().setColorClass(color);
					var sl = $(document.body);
					//console.log("OldClass="+"bg-"+old_color+" NewColor="+"bg-"+color)
					$(".bg-"+old_color).toggleClass(".bg-"+old_color+" bg-"+color);
					$(".text-"+old_color).toggleClass(".text-"+old_color+" text-"+color);
					$(".border-"+old_color).toggleClass(".border-"+old_color+" border-"+color);
				}
			}
		}
	});	
	this.m_form = new WindowFormModalBS(this.getId()+":form",{
		"cmdCancel":true,
		"controlCancelCaption":this.BTN_CANCEL_CAP,
		"controlCancelTitle":this.BTN_CANCEL_TITLE,
		"cmdOk":false,
		"controlOkCaption":null,
		"controlOkTitle":null,
		"onClickCancel":function(){
			self.closeSelect();
		},		
		"onClickOk":function(){
			//self.setValue(self.m_view.getValue());
			self.closeSelect();
		},				
		"content":this.m_view,
		"contentHead":"Цветовая схема"
	});

	this.m_form.open();	
}
EditColorPalette.prototype.closeSelect = function(){
	if (this.m_view){
		this.m_view.delDOM();
		delete this.m_view;
	}
	if (this.m_form){
		this.m_form.close();
		delete this.m_form;
	}		
}

