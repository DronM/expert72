/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2017
 
 * @class
 * @classdesc Visual error control
 
 * @param {string} id
 * @param {Object} options
 * @param {string} [options.errorClassName=this.DEF_ERROR_CLASS]
 */
function ErrorControl(id,options){
	options = options || {};
	
	options.template = window.getApp().getTemplate("ErrorControl");
	options.visible = false;
	
	ErrorControl.superclass.constructor.call(this, id, "SPAN", options);
	
}
extend(ErrorControl,Control);

/* constants */
ErrorControl.prototype.DEF_TAG = "SPAN";

ErrorControl.prototype.setValue = function(val){
	if (!val || val.trim()==""){
		DOMHelper.addClass(this.getNode(),"hidden");
	}
	else{
		DOMHelper.delClass(this.getNode(),"hidden");
	}
	var node;
	if (this.m_node.childNodes){
		for (var i=0;i<this.m_node.childNodes.length;i++){
			if (this.m_node.childNodes[i].nodeType==3){
				this.m_node.childNodes[i].parentNode.removeChild(this.m_node.childNodes[i]);
				break;
			}
		}
	}
	if (!node){
		node = document.createTextNode(val);
		DOMHelper.insertAfter(node,DOMHelper.firstChildElement(this.m_node));		
	}
	node.nodeValue = val;
}
ErrorControl.prototype.clear = function(){
	this.setValue("");
}
