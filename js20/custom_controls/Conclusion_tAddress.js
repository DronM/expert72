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
function Conclusion_tAddress(id,options){
	options = options || {};
		
	options.addElement = function(){
	
		var lb_col = window.getBsCol(4);

		this.addElement(new EditString(id+":Country",{
			"maxLength":"200"
			,"labelCaption":"Страна:"
			,"title":"Необязательный элемент."
		}));								
		
		this.addElement(new ConclusionDictionaryDetailEdit(id+":Region",{
			"labelClassName":"control-label contentRequired "+lb_col
			,"required":"true"
			,"labelCaption":"Регион:"
			,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 8."
			,"conclusion_dictionary_name":"tRegionsRF"
			,"focus":true
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
	
	Conclusion_tAddress.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tAddress,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tAddress_View(id,options){
	options.viewClass = Conclusion_tAddress;
	options.viewOptions = {"name": options["name"]};
	//options.viewTemplate = "Conclusion_tAddress_View";
	options.headTitle = "Редактирование адреса";
	options.dialogWidth = "30%";
	options.strictValidation = true;
	Conclusion_tAddress_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tAddress_View,EditModalDialogXML);

Conclusion_tAddress_View.prototype.formatValue = function(val){
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


