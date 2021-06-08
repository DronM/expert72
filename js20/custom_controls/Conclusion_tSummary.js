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
function Conclusion_tSummary(id,options){
	options = options || {};	
	
	options.addElement = function(){
	
		var lb_col = window.getBsCol(5);
		var ed_col = window.getBsCol(6);
	
		this.addElement(new EditText(id+":EngineeringSurveySummary",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Вывод о соответствии или несоответствии результатов инженерных изысканий требованиям технических регламентов:"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationType равно 1"
			,"focus":true
		}));								

		this.addElement(new EditString(id+":EngineeringSurveySummaryDate",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сведения о дате, по состоянию на которую действовали требования, примененные в соответствии с частью 5.2 статьи 49 Градостроительного кодекса Российской Федерации (в части экспертизы результатов инженерных изысканий):"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationType равно 1"
		}));								

		this.addElement(new Conclusion_Container(id+":EngineeringSurveyType",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"name":"EngineeringSurveyType"
			,"xmlNodeName":"EngineeringSurveyType"
			,"elementControlClass":ConclusionDictionaryDetailSelect
			,"elementControlOptions":{
				"labelCaption":"Вид инженерных изысканий:"
				,"name":"EngineeringSurveyType"
				,"title":"Обязательный элемент. Указывается код из классификатора – Таблица 12."
				,"conclusion_dictionary_name":"tEngineeringSurveyType"				
			}
			,"deleteTitle":"Удалить вид инженерных изысканий, на соответствие которым проводилась экспертиза проектной документации"
			,"deleteConf":"Удалить вид инженерных изысканий?"
			,"addTitle":"Добавить вид инженерных изысканий, на соответствие которым проводилась экспертиза проектной документации"
			,"addCaption":"Добавить вид инженерных изысканий"
		}));								

		this.addElement(new EditText(id+":ProjectDocumentsSummary",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Вывод о соответствии или несоответствии технической части проектной документации результатам инженерных изысканий, заданию застройщика или технического заказчика на проектирование и требованиям технических регламентов:"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationType равно 2"
		}));								
		this.addElement(new EditString(id+":ProjectDocumentsSummaryDate",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сведения о дате, по состоянию на которую действовали требования, примененные в соответствии с частью 5.2 статьи 49 Градостроительного кодекса Российской Федерации (в части экспертизы проектной документации):"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationType равно 2 и отсутствуют сведения о несоответствии проектной документации установленным требованиям"
		}));								


		this.addElement(new EditText(id+":EstimateNormsAndWorksSummary",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Вывод о соответствии (несоответствии) расчетов,содержащихся в сметной сметным нормативам, сведения о которых включены в федеральный реестр сметных нормативов, физическим объемам работ,конструктивным,организационно-технологическим и другим решениям, предусмотренным проектной документацией или Выводы о соответствии (несоответствии) расчетов,содержащихся в сметной документации, физическим объемам работ, включенным в ведомость объемов работ или акт, утвержденный застройщиком или техническим заказчиком и содержащий перечень дефектов оснований, строительных конструкций, систем инженерно-технического обеспечения и сетей инженерно-технического обеспечения с указанием качественных и количественных характеристик таких дефектов, при проведении проверки достоверности определения сметной стоимости капитального ремонта:"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationType равно 3"
		}));								
		
		this.addElement(new EditText(id+":EstimateSummary",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Вывод о достоверности определения сметной стоимости строительства,капитального ремонта,сноса объекта кап. строительства, работ по сохранению объектов культурного наследия народов РФ:"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationType равно 3"
		}));								
		
		this.addElement(new EditText(id+":ExaminationSummary",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Общие выводы (итоговые выводы по результатам проведенной экспертизы):"
			,"title":"Обязательный элемент."
		}));								
		
		
	}
	
	Conclusion_tSummary.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tSummary,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tSummary_View(id,options){

	options.viewClass = Conclusion_tSummary;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tSummary_View";
	options.headTitle = "Выводы по результатам проведения экспертизы";
	options.dialogWidth = "80%";
	
	Conclusion_tSummary_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tSummary_View,EditModalDialogXML);
