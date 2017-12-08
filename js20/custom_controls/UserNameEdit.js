/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
 */
function UserNameEdit(id,options){
	options = options || {};

	options.labelCaption = "Наименование:",
	options.placeholder = "Краткое наименование пользователя",
	options.required = true;
	options.maxlength = 50;
	
	UserNameEdit.superclass.constructor.call(this,id,options);
	
}
extend(UserNameEdit,EditString);

