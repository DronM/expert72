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
		var bs = window.getBsCol(4);
		
		if (!options.clientTypePerson){
			this.addElement(new EditString(id+":dep",{
				"labelCaption":"Отдел:",
				"attrs":{"autofocus":!options.calcPercent},
				"maxLength":"150",
				"autofocus":true
			}));
		}		
		
		this.addElement(new EditString(id+":name",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"labelCaption":"ФИО:",
			"attrs":{"autofocus":options.calcPercent},
			"maxLength":"150",
			"autofocus":(options.clientTypePerson===true)
		}));
		
		if (options.showPost || !options.clientTypePerson){
			this.addElement(new EditString(id+":post",{
				"labelClassName":"control-label "+bs+( options.showPost? " percentcalc":""),
				"labelCaption":"Должность:",
				"maxLength":"150"
			}));
		}
		
		this.addElement(new EditPhone(id+":tel",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"labelCaption":"Телефон:"
		}));
		
		this.addElement(new EditEmail(id+":email",{
			"labelClassName":"control-label "+bs+( options.calcPercent? " percentcalc":""),
			"labelCaption":"Эл.почта:"
		}));

		if (!options.clientTypePerson && !options.calcPercent){
			this.addElement(new Enum_responsable_person_types(id+":person_type",{
				"labelCaption":"Вид должн.лица:"
			}));
		}		
	}
	
	ClientResponsablePersonEdit.superclass.constructor.call(this,id,options);
	
	if (options.calcPercent){
		this.getElement("name").setRequired(true);
		this.getElement("tel").setRequired(true);
		this.getElement("email").setRequired(true);
	}
	
	
}
//ViewObjectAjx,ViewAjxList
extend(ClientResponsablePersonEdit,EditJSON);

/* Constants */


/* private members */

/* protected*/


/* public methods */

