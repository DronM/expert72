/* Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
*/
function UserDialog_View(id,options){	

	options = options || {};
	options.controller = new User_Controller();
	options.model = options.models.UserDialog_Model;
	
	options.templateOptions = options.templateOptions || {};
	options.templateOptions.adm = (window.getApp().getServVar("role_id")=="admin");
	
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
		
		if (options.templateOptions.adm){
			this.addElement(new ButtonCmd(id+":cmdHide",{
				//"visible":true,
				"onClick":function(){
					self.hideUser();
				},
				"caption":"Скрыть пользователя"
			}));		
		}		
		
		this.addElement(new EditCheckBox(id+":reminders_to_email",{
			"labelCaption":"Дублировать напоминания на электронную почту"
		}));								
		
		this.addElement(new EditFile(id+":private_file",{
			"attrs":{"access":"application/x-pkcs12"},
			"labelClassName": "control-label",
			"labelCaption":"Файл ключа (pkcs12 контейнер)",
			"template":window.getApp().getTemplate("EditFile"),
			"mainView":this,
			"onDeleteFile":function(fileId,callBack){
				self.deleteKey(fileId,callBack);
			},
			"onFileAdded":function(fileId){
				self.addKey(fileId);
			}
		}));	
		
		this.addElement(new EditCheckBox(id+":allow_ext_contracts",{
			"labelCaption":"Разрешить внебрачные контракты:"
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
		,new DataBinding({"control":this.getElement("private_file")})
		,new DataBinding({"control":this.getElement("allow_ext_contracts")})
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
		,new CommandBinding({"control":this.getElement("allow_ext_contracts")})
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

UserDialog_View.prototype.deleteKey = function(fileId,callBack){
	var self = this;
	WindowQuestion.show({
		"text":"Удалить ключ?",
		"cancel":false,
		"callBack":function(res){			
			if (res==WindowQuestion.RES_YES){
				var pm = self.getController().getPublicMethod("private_delete");
				pm.setFieldValue("user_id",self.getElement("id").getValue());
				pm.setFieldValue("file_id",fileId);
				pm.run({
					"ok":callBack
				});
			}
		}
	});			
}

UserDialog_View.prototype.addKeyCont = function(pwdVal){
	var pm = this.getController().getPublicMethod("private_put");
	pm.setFieldValue("user_id",this.getElement("id").getValue());
	pm.setFieldValue("private_file_data", this.getElement("private_file").getValue());
	pm.setFieldValue("pwd", pwdVal);
	var self = this;
	pm.run({
		"ok":function(){			
			window.showTempNote("Файл загружен",null,3000);
		}
		,"all":function(){
			self.m_pwdForm.closeView();
		}
	});
}

UserDialog_View.prototype.addKey = function(fileId){
	//password
	var self = this;
	this.m_pwdView = new EditJSON("pwd:cont",{
		"elements":[
			new EditPassword("pwd:cont:pwd_val",{
				"focus":true,
				"labelCaption":"Пароль контейнера:",
				"events":{
					"keydown":function(e){
						if (e.keyCode==13){
							self.m_pwdForm.sendFile();
						}											
					}
				}
			})
		]
	});
	this.m_pwdForm = new WindowFormModalBS("pwd",{
		"content":this.m_pwdView,
		"cmdCancel":true,
		"cmdOk":true,
		"onClickCancel":function(){
			self.m_pwdForm.closeView();
		},
		"onClickOk":function(){
			self.m_pwdForm.sendFile();
		}
	});
	this.m_pwdForm.sendFile = function(){
		var res = self.m_pwdView.getValueJSON();
		if(!res||!res.pwd_val||!res.pwd_val.length){
			throw new Error("Не указан пароль!");
		}
		self.addKeyCont(res.pwd_val);	
	}
	this.m_pwdForm.closeView = function(){
		self.m_pwdView.delDOM()
		self.m_pwdForm.delDOM();
		delete self.m_pwdView;
		delete self.m_pwdForm;			
	}	
	this.m_pwdForm.open();
}
