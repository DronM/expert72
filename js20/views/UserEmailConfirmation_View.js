/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ViewAjxList
 * @requires core/extend.js
 * @requires controls/ViewAjxList.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function UserEmailConfirmation_View(id,options){
	options = options || {};	
	options.template = window.getApp().getTemplate("UserEmailConfirmation_View");
	options.templateOptions = {
		"email":window.getApp().getServVar("user_email"),
		"doNotNotifyChecked":((window.getApp().getDoNotNotifyOnEmailConfirmation())? "checked":"")
	};
	
	this.m_onClose = options.onClose;	
	var self = this;
	
	options.addElement = function(){
		this.addElement(new ButtonCmd(id+":cmdConfirm",{
			"caption":"Отправить письмо",
			"onClick":function(){
				(new User_Controller()).getPublicMethod("send_email_confirm").run({
					"ok":function(){
						window.showNote("На адрес "+window.getApp().getServVar("user_email")+" было отправлено письмо со ссылкой.");
					},
					"all":function(){
						if(self.m_onClose){
							self.m_onClose.call(self);
						}					
					}
				})
			}
		}))
	}
	
	UserEmailConfirmation_View.superclass.constructor.call(this,id,"DIV",options);
	
	$(".doNotNotifyOnEmailConfirmation").click(function(){
		var checked = $("#doNotNotifyOnEmailConfirmation").is(":checked");
		window.getApp().setDoNotNotifyOnEmailConfirmation(checked);
	});
	
	
}
//ViewObjectAjx,ViewAjxList
extend(UserEmailConfirmation_View,ControlContainer);

