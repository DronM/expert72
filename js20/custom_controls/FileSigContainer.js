/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ControlContainer
 * @requires core/extend.js
 * @requires controls/ControlContainer.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 */
function FileSigContainer(id,options){

	options = options || {};	
	
	this.m_onSignFile = options.onSignFile;
	this.m_onSignClick = options.onSignClick;
	this.m_fileId = options.fileId;
	this.m_itemId = options.itemId;
	this.m_multiSignature = options.multiSignature;
	
	this.m_readOnly = options.readOnly;
	this.m_signatures = new ControlContainer(id+":sigs","SPAN");
	if (options.signatures){
		for(var i=0;i<options.signatures.length;i++){
			this.addSignature(options.signatures[i]);
		}
	}
	
	FileSigContainer.superclass.constructor.call(this,id,"SPAN",options);		
}
//ViewObjectAjx,ViewAjxList
extend(FileSigContainer,Control);

/* Constants */
FileSigContainer.prototype.IMG_WAIT = "fa fa-spinner fa-spin";
FileSigContainer.prototype.IMG_KEY = "icon-key";

/* private members */
FileSigContainer.prototype.m_addSignControl;
FileSigContainer.prototype.m_onSignFile;
FileSigContainer.prototype.m_multiSignature;
FileSigContainer.prototype.m_signatures;
FileSigContainer.prototype.m_fileId;
FileSigContainer.prototype.m_itemId;

/* protected*/


/* public methods */

/*
 * @param {object} signature id,check_result,owner,check_time,error_str,create_dt
 */
FileSigContainer.prototype.addSignature = function(signature){
	if (!signature || !signature.id)return;
	var ctrl = new ControlContainer(this.m_signatures.getId()+":"+signature.id,"SPAN",{
		"className": ("btn btn-sm fileSigInfoBtn" + ((signature&&(signature.check_result||signature.check_result==undefined))? "":" border-danger") ),
		"events":{
			"click":function(e){
				if (self.m_onSignClick){
					self.m_onSignClick(self.m_fileId,self.m_itemId);
				}
			}
		}
	});
	var self = this;
	ctrl.certInf = new ToolTip({
		"wait":1000,
		"onHover":function(e){
			if (this.signature&&this.signature.check_result!=undefined){
			
				var add_field = function(field,str,sep){
					sep = sep? sep:", ";
					if (field){
						str+= str.length? sep:"<div>";
						str+= field;
					}
					return str;
				}
			
				if (signature.check_result){				
					var org="";
					org=add_field(signature.owner["ИНН"],org);
					org=add_field(signature.owner["ОГРН"],org);
					org=add_field(signature.owner["Организация"],org);				
					org+= org.length? "</div>":"";

					var pers="";
					pers=add_field(signature.owner["Фамилия"],pers);
					pers=add_field(signature.owner["Имя"],pers," ");
					pers=add_field(signature.owner["Должность"],pers);
					pers=add_field(signature.owner["СНИЛС"],pers);
					pers=add_field(signature.owner["Адрес"],pers);				
					pers=add_field(signature.owner["Эл.почта"],pers);
					pers+= pers.length? "</div>":"";
			
					cont ='<div>' +
						'<div>'+
							'<i class="glyphicon glyphicon-ok"></i>'+
							' <strong>Подпись проверена</strong>'+
						'</div>'+
						(org.length? org:"") +
						(pers.length? pers:"") +
						(this.signature.create_dt? "<div>Подписан: "+CommonHelper(this.signature.create_dt,"d/m/Y H:i")+"</div>":"")
					"</div>";
				}
				else{
					cont ='<div>' +
						'<i class="glyphicon glyphicon-remove"></i>'+
						' <strong>Ошибка проверки подписи</strong>'+
						"<div>"+signature.error_str+"</div>"+
					"</div>";
			
				}					
				this.popup(cont,{"event":e,"width":800});
			}
			else{
				/* нет информации - подпись была добавлена готовым файлом в браузер
				 * если файл загружен - вернем информацию о проверенной подписи
				*/
			}
		},
		"node":ctrl.getNode()
	});
	ctrl.certInf.signature = signature;
	ctrl.addElement(new Control(this.getId()+":"+signature.id+":pic","I",{
		"className":"icon-lock"
	}));
	this.m_signatures.addElement(ctrl);
}

FileSigContainer.prototype.sigsToDOM = function(){

	this.m_signatures.delDOM();
	if (this.m_addSignControl)this.m_addSignControl.delDOM();
	this.m_signatures.toDOM(this.getNode());
	
	if (!this.m_readOnly){
		var cades = window.getApp().getCadesAPI();
		if (cades){
			var self = this;
			this.m_addSignControl = new ControlContainer(this.getId()+":addSign","SPAN",{
				"className":"btn btn-sm"+( this.m_signatures.getCount()? "":" fileSignNoSig"),
				"title":"Подписать файл ЭЦП",
				"visible":(cades.getCertListCount() && (!this.m_signatures.getCount() || this.m_multiSignature) ),
				"elements":[
					new Control(this.getId()+":addSign:pic","I",{
						"className":this.IMG_KEY
					})						
				],
				"events":{
					"click":function(e){
						//what if buisy?
						if (DOMHelper.hasClass(self.m_addSignControl.getElement("pic").getNode(),self.IMG_KEY)){
							self.m_onSignFile(self.m_fileId,self.m_itemId);
						}
					}
				}
			});
			this.m_addSignControl.toDOM(this.m_signatures.getNode());
		}	
	}	
}

FileSigContainer.prototype.toDOM = function(parent){
	FileSigContainer.superclass.toDOM.call(this,parent);
	
	this.sigsToDOM();	
}

FileSigContainer.prototype.delDOM = function(){
	this.m_signatures.delDOM();
	FileSigContainer.superclass.delDOM.call(this);
}
/*
FileSigContainer.prototype.setAddSignVisible = function(v){
	if (this.m_addSignControl)this.m_addSignControl.setVisible(v);
}
*/

FileSigContainer.prototype.setWait = function(v){
	if (this.m_addSignControl){
		this.m_addSignControl.getElement("pic").setClassName(v? this.IMG_WAIT:this.IMG_KEY);
	}	
}
