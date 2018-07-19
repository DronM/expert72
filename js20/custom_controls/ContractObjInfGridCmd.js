/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>,2016

 * @class
 * @classdesc
 
 * @requires core/extend.js  
 * @requires controls/GridCmd.js

 * @param {string} id Object identifier
 * @param {namespace} options
*/
function ContractObjInfGridCmd(id,options){
	options = options || {};	

	options.showCmdControl = true;
	options.glyph = "glyphicon-print";
	options.controls = [
		new ContractObjInfBtn(id+":btn",{
			"controller":options.controller,
			"getContractId":options.getContractId
		})
	];

	ContractObjInfGridCmd.superclass.constructor.call(this,id,options);
		
}
extend(ContractObjInfGridCmd,GridCmd);

/* Constants */


/* private members */

/* protected*/


/* public methods */
