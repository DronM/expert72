/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
 */
function UserProfile_View(id,options){	

	options = options || {};
	
	options.cmdOkAsync = false;
	options.cmdOk = false;
	options.cmdCancel = false;
	
	var user_email_confirmed = (window.getApp().getServVar("user_email_confirmed")=="t");
	options.templateOptions = {
		"email_not_confirmed":!user_email_confirmed
	}
	
	var self = this;
	options.addElement = function(){
		this.addElement(new HiddenKey(id+":id"));	
	
		this.addElement(new UserNameEdit(id+":name",{			
			"labelCaption":"Логин:",
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

		this.addElement(new EditInt(id+":cades_load_timeout",{
			"labelCaption":"Время загрузки плагина, (мс.)",
			"events":{
				"keyup":function(){
					self.getControlSave().setEnabled(true);
				}
			}						
		}));								
		this.addElement(new EditInt(id+":cades_chunk_size",{
			"labelCaption":"Размер части файла при подписании, байт",
			"events":{
				"keyup":function(){
					self.getControlSave().setEnabled(true);
				}
			}								
		}));								

		this.addElement(new EditCheckBox(id+":reminders_to_email",{
			"labelCaption":"Дублировать напоминания на электронную почту",
			"visible":(window.getApp().getServVar("role_id")!="client"),
			"events":{
				"change":function(){
					self.getControlSave().setEnabled(true);
				}
			}						
		}));								

		if(!user_email_confirmed){
			this.addElement(new UserEmailConfirmation_View(id+":email_confirmation"));
		}
	
	}
	
	UserProfile_View.superclass.constructor.call(this,id,options);
		

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
		new DataBinding({"control":this.getElement("cades_load_timeout")}),
		new DataBinding({"control":this.getElement("cades_chunk_size")}),
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
		new CommandBinding({"control":this.getElement("cades_load_timeout")}),
		new CommandBinding({"control":this.getElement("cades_chunk_size")}),
		new CommandBinding({"control":this.getElement("reminders_to_email")})
	]);
	
	this.getControlSave().setEnabled(false);
	
	$(".doNotCadesLoadPlugin").click(function(){
		var checked = $("#doNotCadesLoadPlugin").is(":checked");
		window.getApp().setDoNotLoadCadesPlugin(checked);
	});
	
}
extend(UserProfile_View,ViewObjectAjx);

