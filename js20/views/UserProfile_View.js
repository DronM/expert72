/** Copyright (c) 2017,2019
 *	Andrey Mikhalevich, Katren ltd.
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
	
	var role_id = window.getApp().getServVar("role_id");
	options.templateOptions.is_employee = (role_id!="client");
	
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
			"visible":(role_id!="client"),
			"events":{
				"change":function(){
					self.getControlSave().setEnabled(true);
				}
			}						
		}));								

		this.addElement(new WindowMessageStyleCtrl(id+":win_message_style",{
			"onValueChange":function(){
				self.getControlSave().setEnabled(true);
			}
		}));								

		if(!user_email_confirmed){
			this.addElement(new UserEmailConfirmation_View(id+":email_confirmation"));
		}
	
		//ссылка на сотрудника
		if(options.templateOptions.is_employee){
			this.addElement(new ButtonCmd(id+":cmdEmployeeRef",{
				"caption":" Карточка сотрудника ",
				"glyph":" glyphicon-user",
				"title":"Открыть карточку сотрудника",
				"onClick":function(){	
					self.openEmployeeDialogForm();
				}
			}));
			
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
		new DataBinding({"control":this.getElement("reminders_to_email")}),
		new DataBinding({"control":this.getElement("win_message_style")})
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
		new CommandBinding({"control":this.getElement("reminders_to_email")}),
		new CommandBinding({"control":this.getElement("win_message_style")})
	]);
	
	this.getControlSave().setEnabled(false);
	
	$(".doNotCadesLoadPlugin").click(function(){
		var checked = $("#doNotCadesLoadPlugin").is(":checked");
		window.getApp().setDoNotLoadCadesPlugin(checked);
	});
	
}
extend(UserProfile_View,ViewObjectAjx);

UserProfile_View.prototype.onSave = function(okFunc,failFunc,allFunc){	
	var _okFunc = okFunc;
	var self = this;
	okFunc = function(){
		var struc = window.getApp().getWinMessageStyle();
		struc.win_width = self.getElement("win_message_style").getElement("win_width").getValue();
		struc.win_position = self.getElement("win_message_style").getElement("win_position").getValue();
		if(_okFunc)_okFunc.call(self);
	}
	UserProfile_View.superclass.onSave.call(this,okFunc,failFunc,allFunc);
}

UserProfile_View.prototype.openEmployeeDialogForm = function(){
	var emp_id = this.getModel().getFieldValue("employee_id");
	if(!emp_id){
		throw Error("Карточка сотрудника не найдена!");
	}
	var f = new EmployeeDialog_Form({
		"keys":{"id":emp_id}
	});
	f.open();
	//alert("openEmployeeDialogForm")
}


