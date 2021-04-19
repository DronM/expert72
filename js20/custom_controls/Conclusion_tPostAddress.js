/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2021

 * @extends EditXML
 * @requires core/extend.js
 * @requires controls/EditXML.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function Conclusion_tPostAddress(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);
	
		this.addElement(new ConclusionDictionaryDetailEdit(id+":Region",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Регион:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 8."
			,"conclusion_dictionary_name":"tRegionsRF"
			,"focus":true
		}));								

		this.addElement(new EditNum(id+":PostIndex",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"maxLength":"6"
			,"labelCaption":"Почтовый индекс:"
			,"title":"Обязательный элемент.Строгий формат – 6 цифр."
		}));								

		
		this.addElement(new EditString(id+":District",{
			"maxLength":"200"
			,"labelCaption":"Район:"
			,"title":"Необязательный элемент."
		}));								

		this.addElement(new EditString(id+":City",{
			"maxLength":"200"
			,"labelCaption":"Город:"
			,"title":"Необязательный элемент."
		}));								
		
		this.addElement(new EditString(id+":Settlement",{
			"maxLength":"200"
			,"labelCaption":"Населенный пункт:"
			,"title":"Необязательный элемент."
		}));								
		
		this.addElement(new EditString(id+":Street",{
			"maxLength":"200"
			,"labelCaption":"Улица:"
			,"title":"Необязательный элемент."
		}));								
		
		this.addElement(new EditString(id+":Building",{
			"maxLength":"200"
			,"labelCaption":"Номер здания/сооружения:"
			,"title":"Необязательный элемент."
		}));								
		
		this.addElement(new EditString(id+":Room",{
			"maxLength":"200"
			,"labelCaption":"Номер помещения:"
			,"title":"Необязательный элемент."
		}));								
		
		this.addElement(new EditText(id+":Note",{
			"labelCaption":"Неформализованное описание адреса:"
			,"title":"Необязательный элемент."
		}));								
	
	}
	
	Conclusion_tPostAddress.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tPostAddress,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tPostAddress_View(id,options){
	options.viewClass = Conclusion_tPostAddress;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tPostAddress_View";
	options.headTitle = "Редактирование почтового адреса";
	options.dialogWidth = "30%";
	
	Conclusion_tPostAddress_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tPostAddress_View,EditModalDialogXML);


Conclusion_tPostAddress_View.prototype.formatValue = function(val){
	var reg_descr;
	if(val && val.childNodes) {
		var n_list = val.getElementsByTagName("sysValue");
		if(n_list&&n_list.length&&n_list[0].textContent&&n_list[0].textContent.length){
			var reg = CommonHelper.unserialize(n_list[0].textContent);
			reg_descr = reg.getDescr();
		}
	}
	return	(reg_descr? reg_descr+", ":"") +
		this.formatValueOnTags(
			val
			,[{"tagName":"District","sep":", р-н ","notFirst":true}
			,{"tagName":"City","sep":", г.","notFirst":true}
			,{"tagName":"Settlement","sep":", нас.пункт "}
			,{"tagName":"Street","sep":", ул.","notFirst":true}
			,{"tagName":"Building","sep":", д.","notFirst":true}
			,{"tagName":"Room","sep":", кв.","notFirst":true}
			]
		);
}


