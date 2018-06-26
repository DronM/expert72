/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends ButtonCtrl
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {Object} options
 * @param {string} options.className
 */
function BtnEndDate(id,options){

	options.glyph = "glyphicon-chevron-left";
	options.title="Рассчитать дату окончания";
	
	var self = this;
	options.onClick = function(){
		self.getNextNum();
	}
	
	
	this.m_view = options.view;
	
	BtnEndDate.superclass.constructor.call(this,id,options);
}
extend(BtnEndDate,ButtonCtrl);

/* Constants */


/* private members */

/* protected*/


/* public methods */
BtnEndDate.prototype.getNextNum = function(){
	var pm = this.m_view.getController().getPublicMethod("get_work_end_date");
	pm.setFieldValue("contract_id", this.m_view.getElement("id").getValue());
	pm.setFieldValue("date_type", this.m_view.getElement("date_type").getValue());
	pm.setFieldValue("work_start_date", this.m_view.getElement("work_start_date").getValue());
	pm.setFieldValue("expertise_day_count", this.m_view.getElement("expertise_day_count").getValue());
	pm.setFieldValue("expert_work_day_count", this.m_view.getElement("expert_work_day_count").getValue());
	var self = this.m_view;
	pm.run({
		"ok":function(resp){
			//console.dir(resp)
			var m = new ModelXML("Date_Model",{
				"fields":["end_dt","work_end_dt"],
				"data":resp.getModelData("Date_Model")
			});
			if (m.getNextRow()){
				self.getElement("work_end_date").setValue(m.getFieldValue("end_dt"));
				self.getElement("expert_work_end_date").setValue(m.getFieldValue("work_end_dt"));
			}
		}
	})
}

