function DocFlowApprovementRecipientEdit(id,options){

	options = options || {};
	
	self = this;
	options.addElement = function(){
		var id = this.getId();
		this.addElement(new EmployeeEditRef(id+":employee",{"attrs":{"autofocus":true}}));
		
		/*this.addElement(new EditText(id+":author_comment",{
			"labelCaption":"Комментарий:"
		}));
		*/

		this.addElement(new Enum_doc_flow_approvement_orders(id+":approvement_order",{
			"labelCaption":"Порядок согласования:",
			"required":options.ord_vis,
			"visible":options.ord_vis,
			"value":"after_preceding"
		}));
	}
		
	DocFlowApprovementRecipientEdit.superclass.constructor.call(this,id,options);
}
extend(DocFlowApprovementRecipientEdit,EditJSON);

