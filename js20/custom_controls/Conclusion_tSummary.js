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
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Вывод о соответствии или несоответствии результатов инженерных изысканий требованиям технических регламентов:"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationType равно 1"
			,"focus":true
		}));								

		this.addElement(new EditText(id+":ProjectDocumentsSummary",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Вывод о соответствии или несоответствии технической части проектной документации результатам инженерных изысканий, заданию застройщика или технического заказчика на проектирование и требованиям технических регламентов:"
			,"title":"Необязательный элемент. Обязательный элемент если значение элемента ExaminationType равно 2"
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
			,"labelCaption":"Вывод о достоверности или недостоверности определения сметной стоимости строительства, реконструкции,капитального ремонта, сноса объекта капитального строительства, работ по сохранению объектов культурного наследия (памятников истории и культуры) народов РФ:"
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
