/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends EditJSON
 * @requires core/extend.js
 * @requires controls/EditJSON.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 */
function ClientResponsablePersonEdit(id,options){
	options = options || {};	

	self = this;
	options.addElement = function(){
		var id = this.getId();
		if (!options.clientTypePerson){
			this.addElement(new EditString(id+":dep",{
				"labelCaption":"Отдел:",
				"attrs":{"autofocus":true},
				"maxLength":"150"
			}));
		}		
		
		this.addElement(new EditString(id+":name",{
			"labelCaption":"ФИО:",
			"maxLength":"150"
		}));
		
		if (!options.clientTypePerson){
			this.addElement(new EditString(id+":post",{
				"labelCaption":"Должность:",
				"maxLength":"150"
			}));
		}
		
		this.addElement(new EditPhone(id+":tel",{
			"labelCaption":"Телефон:"
		}));
		
		this.addElement(new EditEmail(id+":email",{
			"labelCaption":"Эл.почта:"
		}));

		if (!options.clientTypePerson){
			this.addElement(new Enum_responsable_person_types(id+":person_type",{
				"labelCaption":"Вид должн.лица:"
			}));
		}		
	}
	
	ClientResponsablePersonEdit.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(ClientResponsablePersonEdit,EditJSON);

/* Constants */


/* private members */

/* protected*/


/* public methods */
