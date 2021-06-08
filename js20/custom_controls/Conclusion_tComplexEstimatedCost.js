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
function Conclusion_tComplexEstimatedCost(id,options){
	options = options || {};	
	
	options.addElement = function(){
		
		var lb_col = window.getBsCol(9);
		var ed_col = window.getBsCol(2);
		
		this.addElement(new Conclusion_tEstimatedSum(id+":CostBasic",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость в базисном уровне цен:"
			,"focus":true
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":WorksCostBasic",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость строительно-монтажных работ в базисном уровне цен:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":HardwareCostBasic",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость оборудования в базисном уровне цен:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":OtherCostBasic",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость прочих затрат в базисном уровне цен:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":ProjectWorksCostBasic",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость проектно-изыскательских работ в базисном уровне цен:"
			,"placeholder":"тыс.руб."
			,"title":"Обязательный элемент."
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":BackSumCostBasic",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Возвратные суммы в базисном уровне цен:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":Cost",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость в уровне цен, сложившихся на дату представления сметной документации:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":WorksCost",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость строительно-монтажных работ в уровне цен, сложившихся на дату представления сметной документации:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":HardwareCost",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость оборудования в уровне цен, сложившихся на дату представления сметной документации:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":OtherCost",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость прочих затрат в уровне цен, сложившихся на дату представления сметной документации:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":ProjectWorksCost",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сметная стоимость проектно-изыскательских работ в уровне цен, сложившихся на дату представления сметной документаци:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":NDSCost",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Сумма налога на добавленную стоимость:"
		}));								

		this.addElement(new Conclusion_tEstimatedSum(id+":BackSumCost",{
			"required":true
			,"labelClassName":"control-label contentRequired "+lb_col
			,"editContClassName":"input-group "+ed_col
			,"labelCaption":"Возвратные суммы в уровне цен, сложившихся на дату представления сметной документации:"
		}));								

		this.addElement(new EditText(id+":CostComment",{
			"required":false
			,"labelCaption":"Комментарий к сметной стоимости в текущем уровне цен:"
		}));								

	}
	
	Conclusion_tComplexEstimatedCost.superclass.constructor.call(this,id,options);
}
//ViewObjectAjx,ViewAjxList
extend(Conclusion_tComplexEstimatedCost,EditXML);

/* Constants */


/* private members */

/* protected*/


/* public methods */

//****************** VIEW **********************
function Conclusion_tComplexEstimatedCost_View(id,options){

	options.viewClass = Conclusion_tComplexEstimatedCost;
	options.viewOptions = {"name":options["name"]};
	//options.viewTemplate = "Conclusion_tComplexEstimatedCost_View";
	options.headTitle = "Сведения о сметной стоимости";
	options.dialogWidth = "50%";
	
	Conclusion_tComplexEstimatedCost_View.superclass.constructor.call(this,id,options);

}
extend(Conclusion_tComplexEstimatedCost_View,EditModalDialogXML);

