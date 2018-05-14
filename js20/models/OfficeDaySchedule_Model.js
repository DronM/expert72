/**	
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_js.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Model class. Created from template build/templates/models/Model_js.xsl. !!!DO NOT MODEFY!!!
 
 * @extends ModelXML
 
 * @requires core/extend.js
 * @requires core/ModelXML.js
 
 * @param {string} id 
 * @param {Object} options
 */

function OfficeDaySchedule_Model(options){
	var id = 'OfficeDaySchedule_Model';
	options = options || {};
	
	options.fields = {};
	
			
				
				
			
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.office_id = new FieldInt("office_id",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = true;	
	
	filed_options.autoInc = false;	
	
	options.fields.day = new FieldDate("day",filed_options);
	
				
	
	var filed_options = {};
	filed_options.primaryKey = false;	
	
	filed_options.autoInc = false;	
	
	options.fields.work_hours = new FieldJSONB("work_hours",filed_options);
	
		OfficeDaySchedule_Model.superclass.constructor.call(this,id,options);
}
extend(OfficeDaySchedule_Model,ModelXML);

