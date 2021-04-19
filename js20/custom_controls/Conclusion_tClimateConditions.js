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
function Conclusion_tClimateConditions(id,options){
	options = options || {};	
	
	options.template = window.getApp().getTemplate("Conclusion_tClimateConditions");	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(5);		
	
		this.addElement(new Conclusion_Container(id+":ClimateDistrict",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"name":"ClimateDistrict"
			,"xmlNodeName":"ClimateDistrict"
			,"elementControlClass":ConclusionDictionaryDetailSelect
			,"elementControlOptions":{
				"labelCaption":"Климатический район,подрайон:"
				,"name":"ClimateDistrict"
				,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 13."
				,"conclusion_dictionary_name":"tClimateDistrict"				
			}
			,"deleteTitle":"Удалить климатический район"
			,"deleteConf":"Удалить климатический район?"
			,"addTitle":"Добавить климатический район"
			,"addCaption":"Добавить климатический район"
		}));								
		
		this.addElement(new Conclusion_Container(id+":GeologicalConditions",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"name":"GeologicalConditions"
			,"xmlNodeName":"GeologicalConditions"
			,"elementControlClass":ConclusionDictionaryDetailSelect
			,"elementControlOptions":{
				"labelCaption":"Категория сложности инженерно-геологических условий:"
				,"name":"GeologicalConditions"
				,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 14."
				,"conclusion_dictionary_name":"tGeologicalConditions"
			}
			,"deleteTitle":"Удалить категорию сложности инженерно-геологических условий"
			,"deleteConf":"Удалить категорию сложности?"
			,"addTitle":"Добавить категорию сложности инженерно-геологических условий"
			,"addCaption":"Добавить категорию сложности"
		}));								

		this.addElement(new Conclusion_Container(id+":WindDistrict",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"name":"WindDistrict"
			,"xmlNodeName":"WindDistrict"
			,"elementControlClass":ConclusionDictionaryDetailSelect
			,"elementControlOptions":{
				"labelCaption":"Ветровой район:"
				,"name":"WindDistrict"
				,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 15."
				,"conclusion_dictionary_name":"tWindDistrict"
			}
			,"deleteTitle":"Удалить ветровой район"
			,"deleteConf":"Удалить ветровой район?"
			,"addTitle":"Добавить ветровой район"
			,"addCaption":"Добавить ветровой район"
		}));								

		this.addElement(new Conclusion_Container(id+":SnowDistrict",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"name":"SnowDistrict"
			,"xmlNodeName":"SnowDistrict"
			,"elementControlClass":ConclusionDictionaryDetailSelect
			,"elementControlOptions":{
				"labelCaption":"Снеговой район:"
				,"name":"SnowDistrict"
				,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 16."
				,"conclusion_dictionary_name":"tSnowDistrict"
			}
			,"deleteTitle":"Удалить снеговой район"
			,"deleteConf":"Удалить снеговой район?"
			,"addTitle":"Добавить снеговой район"
			,"addCaption":"Добавить снеговой район"
		}));								
		
		this.addElement(new Conclusion_Container(id+":SeismicActivity",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"name":"SeismicActivity"
			,"xmlNodeName":"SeismicActivity"
			,"elementControlClass":ConclusionDictionaryDetailSelect
			,"elementControlOptions":{
				"labelCaption":"Интенсивность сейсмических воздействий:"
				,"name":"SeismicActivity"
				,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 17."
				,"conclusion_dictionary_name":"tSeismicActivity"
			}
			,"deleteTitle":"Удалить интенсивность сейсмических воздействий"
			,"deleteConf":"Удалить элемент?"
			,"addTitle":"Добавить интенсивность сейсмических воздействий"
			,"addCaption":"Добавить элемент"
		}));								
		
		
	}
	
	Conclusion_tClimateConditions.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tClimateConditions,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tClimateConditions_View(id,options){

	options.viewClass = Conclusion_tClimateConditions;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tClimateConditions_View";
	options.headTitle = "Сведения о природных и техногенных условиях территории";
	options.dialogWidth = "50%";
	
	Conclusion_tClimateConditions_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tClimateConditions_View,EditModalDialogXML);

Conclusion_tClimateConditions_View.prototype.formatValue = function(val){
	return	"Климатические районы, инженерно-геологические условия, интенсивность сейсмических воздействий, снеговые районы, ветровые районы"
	;
}


