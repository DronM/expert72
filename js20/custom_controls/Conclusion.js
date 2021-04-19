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
function Conclusion(id,options){
	options = options || {};	
	
	options.addElement = function(){
		var lb_col = window.getBsCol(4);
		
		this.addElement(new EditString(id+":ConclusionGUID",{
			"attrs":{"xmlAttr":true}
			,"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"УИД заключения:"
			,"placeholder":"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
			,"title":"Уникальный идентификатор формирования заключения экспертизы для идентификации при включении сведений и документов в ЕГРЗ"
			,"regExpression":/^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$/
			,"formatterOptions":{
				"delimiter": "-",
				"blocks": [8,4,4,4,12]
			}
		}));								
	
		this.addElement(new EditString(id+":SchemaVersion",{
			"attrs":{"xmlAttr":true}
			,"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Версия схемы:"
			,"placeholder":"xx.xx"
			,"title":"Номер версии схемы, используемой при создании заключения"
			,"regExpression":/^[0-9]{2}-[0-9]{2}$/
			,"formatterOptions":{
				"delimiter": "-",
				"blocks": [2, 2]
			}
		}));								

		this.addElement(new EditString(id+":SchemaLink",{
			"attrs":{"xmlAttr":true}
			,"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"labelCaption":"Ссылка на xml-схему:"
			,"placeholder":"http://"
			,"title":"Ссылка на xml-схему на официальном сайте, где опубликована схема"
			,"regExpression":/^(http)|(https):\/\//
		}));										

		this.addElement(new Conclusion_tOrganization_View(id+":ExpertOrganization",{
			"name":"ExpertOrganization"
			,"required":true
			,"labelCaption":"Сведения об организации по проведению экспертизы:"
			,"title":"Обязательный элемент."
		}));										
		
		
		this.addElement(new Conclusion_tWorkPerson_View(id+":Approver",{
			"name":"Approver"
			,"required":true
			,"labelCaption":"Сведения о лице, утвердившем заключение:"
			,"title":"Обязательный элемент."
		}));										

		this.addElement(new Conclusion_tExaminationObject(id+":ExaminationObject",{
			"name":"ExaminationObject"
			,"required":true
			,"labelCaption":"Сведения об объекте экспертизы:"
			,"title":"Обязательный элемент."
		}));										
		
		this.addElement(new Conclusion_tDocuments(id+":Documents",{
			"name":"Documents"
			,"required":true
			,"labelCaption":"Документы, представленные на экспертизу:"
			,"title":"Обязательный элемент."
		}));										
		
		this.addElement(new Conclusion_tPreviousConclusions(id+":PreviousConclusions",{
			"name":"PreviousConclusions"
			,"required":true
			,"labelCaption":"Сведения о ранее подготовленных заключениях экспертизы:"
			,"title":"Необязательный элемент.Обязательно должен присутствовать, в случае если значение ExaminationStage имеет значение 2 или 3."
		}));										
		
		this.addElement(new Conclusion_tPreviousSimpleConclusions(id+":PreviousSimpleConclusions",{
			"name":"PreviousSimpleConclusions"
			,"required":true
			,"labelCaption":"Сведения о ранее выданных заключениях по результатам оценки соответствия в рамках экспертного сопровождения:"
			,"title":"Необязательный элемент.Обязательно должен присутствовать, в случае если значение ExaminationStage имеет значение 3."
		}));										
		
		this.addElement(new Conclusion_tObject(id+":Object",{
			"name":"Object"
			,"required":true
			,"labelCaption":"Сведения об объекте капитального строительства:"
			,"title":"Обязательный элемент."
		}));										
		
		this.addElement(new Conclusion_tDeclarant(id+":Declarant",{
			"name":"Declarant"
			,"labelCaption":"Сведения о заявителе:"
			,"title":"Обязательный элемент."			
		}));										
		
		this.addElement(new Conclusion_Container(id+":Finance",{
			"name":"Finance"
			,"xmlNodeName":"Finance"
			,"elementControlClass":Conclusion_tFinance
			,"elementControlOptions":{
				"labelCaption":"Сведения об источнике финансирования:"
				,"title":"Обязательный элемент."
			}
			,"deleteTitle":"Удалить источник финансирования"
			,"deleteConf":"Удалить источник финансирования?"
			,"addTitle":"Добавить сведения об источнике финансирования"
			,"addCaption":"Добавить источник финансирования"			
		}));

		this.addElement(new Conclusion_Container(id+":ProjectDocumentsDeveloper",{
			"name":"ProjectDocumentsDeveloper"
			,"elementControlClass":Conclusion_tDeclarant
			,"elementControlOptions":{
				"labelCaption":"Застройщик:"
				,"name":"ProjectDocumentsDeveloper"
			}
			,"deleteTitle":"Удалить застройщика"
			,"deleteConf":"Удалить застройщика?"
			,"addTitle":"Добавить застройщика"
			,"addCaption":"Добавить застройщика"
			,"title":"Застройщик, обеспечивший подготовку проектной документации (внесение изменений в проектную документацию)"
		}));
		
		this.addElement(new Conclusion_Container(id+":ProjectDocumentsTechnicalCustomer",{
			"name":"ProjectDocumentsTechnicalCustomer"
			,"elementControlClass":Conclusion_tTechnicalCustomer
			,"elementControlOptions":{
				"labelCaption":"Технический заказчик ПД:"
				,"name":"ProjectDocumentsTechnicalCustomer"
			}
			,"deleteTitle":"Удалить технического заказчика ПД"
			,"deleteConf":"Удалить технического заказчика ПД?"
			,"addTitle":"Добавить технического заказчика ПД"
			,"addCaption":"Добавить технического заказчика ПД"
		}));

		this.addElement(new Conclusion_Container(id+":CadastralNumber",{
			"name":"CadastralNumber"
			,"xmlNodeName":"CadastralNumber"
			,"elementControlClass":EditString
			,"elementControlOptions":{
				"maxLength":"40"
				,"labelCaption":"Кадастровый номер земельного участка, на котором размещается объект капитального строительства:"
				,"name":"CadastralNumber"
				,"placeholder":"строка:строка:строка:строка"
				,"regExpression":/\d+:\d+:\d+:\d+/
			}
			,"deleteTitle":"Удалить кадастровый номер"
			,"deleteConf":"Удалить кадастровый номер?"
			,"addTitle":"Добавить кадастровый номер земельного участка"
			,"addCaption":"Добавить кадастровый номер"
		}));										
		
		this.addElement(new Conclusion_EditCompound(id+":EstimatedCost",{
			"name":"EstimatedCost"
			,"labelCaption":"Сведения о сметной стоимости:"
			,"title":"Необязательный элемент."
			,"sysNode":false
			,"controlNameToConclusionTagName":false
			,"possibleDataTypes":[
				{"dataType":"EstimatedCompleteCost"
				,"dataTypeDescrLoc":"Полная стоимость"
				,"ctrlClass":Conclusion_tEstimatedCompleteCost_View
				}
				,{"dataType":"EstimatedComplexCost"
				,"dataTypeDescrLoc":"Составная стоимость"
				,"ctrlClass":Conclusion_tEstimatedComplexCost_View
				}
			]
		}));

		this.addElement(new Conclusion_tClimateConditions_View(id+":ClimateConditions",{
			"name":"ClimateConditions"
			,"labelCaption":"Сведения о природных и техногенных условиях территории:"
			,"title":"Необязательный элемент."
		}));
				
		this.addElement(new EditText(id+":ClimateConditionsNote",{
			"labelCaption":"Дополнительные сведения о природных и техногенных условиях территории:"
			,"title":"Необязательный элемент.Произвольное текстовое поле содержит дополнительную информацию о природных и техногенных условиях территории.Обязательно должен присутствовать, в случае если значение элемента ExaminationObjectType равно 2 – в этом случае сведения вносятся из заключения экспертизы в отношении результатов инженерных изысканий, представленное для проведения экспертизы. В остальных случаях описание представляется в заключениях экспертов по направлениям экспертизы результатов инженерных изысканий."
		}));
				
		this.addElement(new Conclusion_Container(id+":Designer",{
			"name":"Designer"
			,"elementControlClass":Conclusion_tDesigner
			,"elementControlOptions":{
				"labelCaption":"Проектная организация:"
				,"name":"Designer"
			}
			,"deleteTitle":"Удалить проектную организацию"
			,"deleteConf":"Удалить проектную организацию?"
			,"addTitle":"Добавить проектную организацию"
			,"addCaption":"Добавить проектную организацию"
		}));

		this.addElement(new Conclusion_tEEPDUse_View(id+":EEPDUse",{
			"name":"EEPDUse"
			,"labelCaption":"Сведения об использовании экономически эффективной проектной документации повторного использования:"
			,"title":"Необязательный элемент.Может присутствовать, в случае если при разработке проектной документации была использована экономически эффективная проектная документация повторного использования и если значение элемента ExaminationObjectType не равно 1"
		}));

		this.addElement(new EditText(id+":ProjectTaskNote",{
			"labelCaption":"Дополнительные сведения о задании на проектирование:"
			,"title":"Необязательный элемент.Произвольное текстовое поле содержит дополнительную информацию о задании на проектирование."
		}));

		this.addElement(new EditText(id+":TerritoryPlanNote",{
			"labelCaption":"Дополнительные сведения о документации по планировке территории:"
			,"title":"Необязательный элемент.Произвольное текстовое поле содержит дополнительную информацию о территориальном планировании."
		}));

		this.addElement(new EditText(id+":NetworkNote",{
			"labelCaption":"Дополнительные сведения о технических условиях подключения к сетям инженерно-технического обеспечения:"
			,"title":"Необязательный элемент.Произвольное текстовое поле содержит дополнительную информацию о технических условиях подключения к инженерным сетям."
		}));

		
		this.addElement(new Conclusion_tEngineeringSurveyAddress_View(id+":EngineeringSurveyAddress",{
			"name":"EngineeringSurveyAddress"
			,"labelCaption":"Местоположение района (площадки, трассы) проведения инженерных изысканий:"
			,"title":"Необязательный элемент."
		}));
		
		this.addElement(new Conclusion_Container(id+":EngineeringSurveyDeveloper",{
			"name":"EngineeringSurveyDeveloper"
			,"xmlNodeName":"EngineeringSurveyDeveloper"
			,"elementControlClass":Conclusion_tDeclarant
			,"elementControlOptions":{
				"labelCaption":"Застройщик:"
				,"name":"EngineeringSurveyDeveloper"
			}
			,"deleteTitle":"Удалить застройщика"
			,"deleteConf":"Удалить застройщика?"
			,"addTitle":"Добавить застройщика"
			,"addCaption":"Добавить застройщика"
			,"title":"Застройщик, обеспечивший подготовку РИИ"
		}));
		
		this.addElement(new Conclusion_Container(id+":EngineeringSurveyTechnicalCustomer",{
			"name":"EngineeringSurveyTechnicalCustomer"
			,"elementControlClass":Conclusion_tTechnicalCustomer
			,"elementControlOptions":{
				"labelCaption":"Технический заказчик РИИ:"
			}
			,"deleteTitle":"Удалить технического заказчика РИИ"
			,"deleteConf":"Удалить технического заказчика РИИ?"
			,"addTitle":"Добавить технического заказчика РИИ"
			,"addCaption":"Добавить технического заказчика РИИ"
		}));

		this.addElement(new Conclusion_Container(id+":ExpertConclusion",{
			"name":"ExpertConclusion"
			,"elementControlClass":Conclusion_tExpertConclusion
			,"elementControlOptions":{
			}
			,"deleteTitle":"Удалить сведение о рассмотрении документации по направленю"
			,"deleteConf":"Удалить сведение?"
			,"addTitle":"Добавить сведение"
			,"addCaption":"Добавить сведение о рассмотрении документации по направленю"
			
			
			,"labelCaption":"Сведения о рассмотрении документации по направлению:"
			,"title":"Обязательный элемент.Обязательное присутствие хотя бы одного элемента в схеме"
		}));
		
		this.addElement(new Conclusion_tSummary(id+":Summary",{
			"name":"Summary"
			,"labelCaption":"Выводы по результатам проведения экспертизы:"
			,"title":"Обязательный элемент."
		}));
		
		this.addElement(new Conclusion_tExperts(id+":Experts",{
			"name":"Experts"
			,"required":true
			,"title":"Список экспертов. Обязательный элемент."
		}));										

	}
	
	Conclusion.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */
Conclusion.prototype.validate = function(){
	return true;
}
