/* Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
*/
function UserDialog_View(id,options){	

	options = options || {};
	options.controller = new User_Controller();
	options.model = options.models.UserDialog_Model;
	
	var self = this;
	
	options.addElement = function(){
		var bs = window.getBsCol();
		
		this.addElement(new HiddenKey(id+":id"));	
		
		this.addElement(new UserNameEdit(id+":name"));	

		this.addElement(new EditString(id+":name_full",{				
			"labelCaption":"ФИО пользователя:"
		}));	

		this.addElement(new Enum_role_types(id+":role",{
			"labelCaption":"Роль:",
			"required":true
		}));	
	
		this.addElement(new EditEmail(id+":email",{
			"required":true,
			"labelCaption":"Эл.почта:"
		}));	

		this.addElement(new EditCheckBox(id+":email_confirmed",{
			"enabled":false,
			"labelCaption":"Адрес эл.почты подтвержден:"
		}));	

		this.addElement(new EditPhone(id+":phone_cel",{
			"labelCaption":"Моб.телефон:"
		}));

		this.addElement(new EditText(id+":comment_text",{
			"labelCaption":"Комментарий:"
		}));

		this.addElement(new EditCheckBox(id+":banned",{
			"labelCaption":"Доступ запрещен:"
		}));
		
		this.addElement(new EditColorPalette(id+":color_palette",{
			"labelCaption":"Цветовая схема:"
		}));	
		
		if (window.getApp().getServVar("role_id")=="admin"){
			this.addElement(new ButtonCmd(id+":cmdHide",{
				//"visible":true,
				"onClick":function(){
					self.hideUser();
				}
			}));		
		}		
		
		this.addElement(new EditCheckBox(id+":reminders_to_email",{
			"labelCaption":"Дублировать напоминания на электронную почту"
		}));								
		
	}
	
	UserDialog_View.superclass.constructor.call(this,id,options);
	
	//****************************************************	
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("id")}),
		new DataBinding({"control":this.getElement("name")}),
		new DataBinding({"control":this.getElement("name_full")}),
		new DataBinding({"control":this.getElement("role"),"field":this.m_model.getField("role_id")}),
		new DataBinding({"control":this.getElement("email")}),
		new DataBinding({"control":this.getElement("email_confirmed")}),
		new DataBinding({"control":this.getElement("phone_cel")}),
		new DataBinding({"control":this.getElement("comment_text")}),
		new DataBinding({"control":this.getElement("banned")}),
		new DataBinding({"control":this.getElement("color_palette")}),
		new DataBinding({"control":this.getElement("reminders_to_email")})
	];
	/*
	if (window.getApp().getServVars().role_id=="client1c"){
	}
	*/
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name")}),
		new CommandBinding({"control":this.getElement("name_full")}),
		new CommandBinding({"control":this.getElement("role"),"fieldId":"role_id"}),
		new CommandBinding({"control":this.getElement("email")}),
		new CommandBinding({"control":this.getElement("phone_cel")}),
		new CommandBinding({"control":this.getElement("comment_text")}),
		new CommandBinding({"control":this.getElement("banned")}),
		new CommandBinding({"control":this.getElement("color_palette")}),
		new CommandBinding({"control":this.getElement("reminders_to_email")})
	]);
	
}
extend(UserDialog_View,ViewObjectAjx);

UserDialog_View.prototype.hideUser = function(){
	var pm = this.getController().getPublicMethod("hide");
	pm.setFieldValue("id",this.getElement("id").getValue());
	var self = this;
	pm.run({
		"ok":function(resp){
			self.close({"updated":true});
		}
	});
}


UserDialog_View.prototype.onGetData = function(resp){
	UserDialog_View.superclass.onGetData.call(this,resp);
		
	var m = this.getModel();
	if (m.getFieldValue("banned")){
		this.getElement("cmdHide").setEnabled(false);	
	}
	
}

