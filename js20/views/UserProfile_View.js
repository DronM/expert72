/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
 */
function UserProfile_View(id,options){	

	options = options || {};
	
	options.cmdOk = false;
	options.cmdCancel = false;
	
	UserProfile_View.superclass.constructor.call(this,id,options);
		
	var self = this;

	this.addElement(new HiddenKey(id+":id"));	
	
	this.addElement(new UserNameEdit(id+":name",{
		"focus":true,
		"events":{
			"keyup":function(){
				self.getControlSave().setEnabled(true);
				self.getElement("name").checkName();
			}
		}
		
	}));	

	this.addElement(new EditString(id+":name_full",{				
		"labelCaption":"ФИО пользователя:"
	}));	

	this.addElement(new UserPwdEdit(id+":pwd",{
		"labelCaption":"Пароль:",
		"view":this,
		"events":{
			"keyup":function(){
				self.getControlSave().setEnabled(true);
			}
		}				
	}));	
	this.addElement(new UserPwdEdit(id+":pwd_confirm",{
		"required":false,
		"labelCaption":"Подтверждение пароля:",
		"view":this
	}));	

	this.addElement(new EditEmail(id+":email",{
		"labelCaption":"Эл.почта:",
		"required":false,
		"events":{
			"keyup":function(){
				self.getControlSave().setEnabled(true);
			}
		}		
	}));	

	this.addElement(new EditPhone(id+":phone_cel",{
		"labelCaption":"Моб.телефон:",
		"events":{
			"keyup":function(){
				self.getControlSave().setEnabled(true);
			}
		}		
	}));	

	this.addElement(new EditColorPalette(id+":color_palette",{
		"labelCaption":"Цветовая схема:",
		"events":{
			"change":function(){
				self.getControlSave().setEnabled(true);
			}
		}				
	}));	

	this.addElement(new EditCheckBox(id+":reminders_to_email",{
		"labelCaption":"Дублировать напоминания на электронную почту"
	}));								

	//****************************************************
	var contr = new User_Controller();
	
	//read
	this.setReadPublicMethod(contr.getPublicMethod("get_profile"));
	this.m_model = options.models.UserProfile_Model;
	
	this.setDataBindings([
		new DataBinding({"control":this.getElement("id"),"model":this.m_model}),
		new DataBinding({"control":this.getElement("name"),"model":this.m_model}),
		new DataBinding({"control":this.getElement("name_full"),"model":this.m_model}),
		new DataBinding({"control":this.getElement("email"),"model":this.m_model}),
		new DataBinding({"control":this.getElement("phone_cel"),"model":this.m_model}),
		new DataBinding({"control":this.getElement("color_palette")}),
		new DataBinding({"control":this.getElement("reminders_to_email")})
	]);
	
	//write
	this.setController(contr);
	this.getCommand(this.CMD_OK).setBindings([
		new CommandBinding({"control":this.getElement("id")}),
		new CommandBinding({"control":this.getElement("name")}),
		new CommandBinding({"control":this.getElement("name_full")}),
		new CommandBinding({"control":this.getElement("email")}),
		new CommandBinding({"control":this.getElement("phone_cel")}),
		new CommandBinding({"control":this.getElement("pwd")}),
		new CommandBinding({"control":this.getElement("color_palette")}),
		new CommandBinding({"control":this.getElement("reminders_to_email")})
	]);
	
	this.getControlSave().setEnabled(false);
}
extend(UserProfile_View,ViewObjectAjx);

