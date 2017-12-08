/** Copyright (c) 2017 
 *  Andrey Mikhalevich, Katren ltd.
 */
function UserEditRef(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Пользователь:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = UserList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = User_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new User_Controller();
	options.acModel = new UserList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	UserEditRef.superclass.constructor.call(this,id,options);
}
extend(UserEditRef,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

