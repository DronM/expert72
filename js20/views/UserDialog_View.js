/* Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
*/
function UserDialog_View(id,options){	

	options = options || {};
	options.controller = new User_Controller();
	options.model = options.models.UserDialog_Model;
	
	UserDialog_View.superclass.constructor.call(this,id,options);
	
	var bs = window.getBsCol();
		
	this.addElement(new UserNameEdit(id+":name"));	

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

	//****************************************************	
	
	//read
	var r_bd = [
		new DataBinding({"control":this.getElement("name")}),
		new DataBinding({"control":this.getElement("role"),"field":this.m_model.getField("role_id")}),
		new DataBinding({"control":this.getElement("email")}),
		new DataBinding({"control":this.getElement("email_confirmed")}),
		new DataBinding({"control":this.getElement("phone_cel")}),
		new DataBinding({"control":this.getElement("comment_text")})
	];
	/*
	if (window.getApp().getServVars().role_id=="client1c"){
	}
	*/
	this.setDataBindings(r_bd);
	
	//write
	this.setWriteBindings([
		new CommandBinding({"control":this.getElement("name")}),
		new CommandBinding({"control":this.getElement("role"),"fieldId":"role_id"}),
		new CommandBinding({"control":this.getElement("email")}),
		new CommandBinding({"control":this.getElement("phone_cel")}),
		new CommandBinding({"control":this.getElement("comment_text")})
	]);
	
}
extend(UserDialog_View,ViewObjectAjx);
