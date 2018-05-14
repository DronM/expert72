/** Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.
 */
function ClientNameFullEdit(id,options){
	options = options || {};

	var self = this;

	if (options.labelCaption==undefined){
		options.labelCaption = "Официальное наименование:";
	}
	options.placeholder = "Наименование в точном соответствии с учредительными документами";
	options.maxLength = 500;
	
	ClientNameEdit.superclass.constructor.call(this,id,options);
	
}
extend(ClientNameFullEdit,EditString);

