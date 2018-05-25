/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017

 * @extends GridPagination
 * @requires core/extend.js  

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {namespace} options
 * @param {string} options.className
 */
function Pagination(id,options){
	options = options || {};	
	
	options.ctrlGoFirstCaption = "⇤";
	options.ctrlGoNextCaption = "⇢";
	options.ctrlGoPrevCaption = "⇠";
	options.ctrlGoLastCaption = "⇥";

	options.ctrlGoFirstGlyph = "";
	options.ctrlGoNextGlyph = "";
	options.ctrlGoPrevGlyph = "";
	options.ctrlGoLastGlyph = "";
	
	options.pageClassName = "page";
	options.pageTagName = "A";
	options.pageCurClassName = "page active";//+window.getApp().COLOR_CLASS;
	options.pagesTagName = "UL";
	options.pagesClassName = "pagination-flat pagination-sm twbs-prev-next pagination";
	
	
	Pagination.superclass.constructor.call(this,id,options);
}
extend(Pagination,GridPagination);

/* Constants */


/* private members */

/* protected*/


/* public methods */

Pagination.prototype.createPageElement = function(options){
	var cont_class = options.className;
	options.className = "page-link";
	return (
		new ControlContainer(null,"LI",{
			"className":cont_class,
			"elements":[new Control(null,"A",options)]
		})
	);
}

