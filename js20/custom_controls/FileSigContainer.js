/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2018

 * @extends ControlContainer
 * @requires core/extend.js
 * @requires controls/ControlContainer.js     

 * @class
 * @classdesc
 
 * @param {string} id - Object identifier
 * @param {object} options
 * @param {bool} [options.multiSignature=false]
 * @param {function} options.onSignFile
 * @param {function} options.onSignClick
 * @param {string} options.fileId
 * @param {string} options.itemId
 * @param {bool} [options.readOnly=false]        
 */
function FileSigContainer(id,options){

	options = options || {};	
	
	this.m_onSignFile = options.onSignFile;
	this.m_onSignClick = options.onSignClick;
	this.m_fileId = options.fileId;
	this.m_itemId = options.itemId;
	this.m_multiSignature = (options.multiSignature!=undefined)? options.multiSignature:false;
	
	this.m_readOnly = (options.readOnly!=undefined)? options.readOnly : false;
	
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
 * @param {object} signature id,check_result,owner,check_time,error_str,sign_date_time
 */
FileSigContainer.prototype.addSignature = function(signature){
	if (!signature||!signature.sign_date_time)return;
	//this.m_signatures.getId()+":"+signature.id
	var ctrl = new ControlContainer(null,"SPAN",{
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
			if (this.signature){
				var add_field = function(field,str,sep,bld){
					sep = sep? sep:", ";
					if (field){
						str+= str.length? sep:"<div>";
						str+= (bld? ("<strong>"+field+"</strong>") : field);
					}
					return str;
				}
			
				if (signature.check_result){				
					//Подпись проверена - ОК
					var sign_date_time_s;
					if (this.signature.sign_date_time){
						sign_date_time_d = (typeof(this.signature.sign_date_time)=="string")?
							DateHelper.strtotime(this.signature.sign_date_time) : this.signature.sign_date_time;
					}
					var org="";
					org=add_field(signature.owner["ИНН"],org);
					org=add_field(signature.owner["ОГРН"],org);
					org=add_field(signature.owner["Организация"],org);				
					org+= org.length? "</div>":"";

					var pers="";
					pers=add_field(signature.owner["Фамилия"],pers,null,true);
					pers=add_field(signature.owner["Имя"],pers," ",true);
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
						(this.signature.sign_date_time? "<div>Подписан: "+DateHelper.format(sign_date_time_d,"d/m/Y H:i")+"</div>":"")+
						((this.signature.cert_from&&this.signature.cert_to)? "<div>Действует с "+DateHelper.format(DateHelper.strtotime(this.signature.cert_from),"d/m/Y")+" до "+DateHelper.format(DateHelper.strtotime(this.signature.cert_to),"d/m/Y")+
								((this.signature.cert_to&&DateHelper.strtotime(this.signature.cert_to)<DateHelper.time())? "<div class='badge badge-danger'>Просрочена</div>":"")+
								"</div>":""
						)						
					"</div>";
				}
				else if (signature.check_result==undefined){
					/* Подпись НЕ проверена, не загружена
					 * нет информации - подпись была добавлена готовым файлом в браузер
					 */
					var org="";
					var pers="";
					if (signature.owner){
						org=add_field(signature.owner["ИНН"],org);
						org=add_field(signature.owner["ОГРН"],org);
						org=add_field(signature.owner["Организация"],org);				
						org+= org.length? "</div>":"";
						
						pers=add_field(signature.owner["Фамилия"],pers);
						pers=add_field(signature.owner["Имя"],pers," ");
						pers=add_field(signature.owner["Должность"],pers);
						pers=add_field(signature.owner["СНИЛС"],pers);
						pers=add_field(signature.owner["Адрес"],pers);				
						pers=add_field(signature.owner["Эл.почта"],pers);
						pers+= pers.length? "</div>":"";
					}
										 
					cont ='<div>' +
						'<div>'+
							'<i class="glyphicon  glyphicon-question-sign"></i>'+
							' <strong>Подпись не проверена</strong>'+
						'</div>'+
						(org.length? org:"") +
						(pers.length? pers:"") +
					"</div>";
				}
				else{
					//Подпись проверена - ОШИБКА
					cont ='<div>' +
						'<i class="glyphicon glyphicon-remove"></i>'+
						' <strong>Ошибка проверки подписи</strong>'+
						(signature.error_str? "<div>"+signature.error_str+"</div>" : "")+
					"</div>";
			
				}					
				this.popup(cont,{"event":e,"width":800});
			}
		},
		"node":ctrl.getNode()
	});
	ctrl.certInf.signature = signature;
	//this.getId()+":"+signature.id+":pic"
	ctrl.addElement(new Control(null,"I",{
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
			var cert_cnt = cades.getCertListCount();		
			var sig_cnt = this.m_signatures.getCount();
			var vs=(cert_cnt && (!sig_cnt || this.m_multiSignature) );
			var self = this;
			
			this.m_addSignControl = new ControlContainer(this.getId()+":addSign","SPAN",{
				"className":"btn btn-sm"+( (this.m_signatures.getCount()&&!this.m_multiSignature)? "":" fileSignNoSig"),
				"title":"Подписать файл выбранной подписью",
				"visible":vs,
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

FileSigContainer.prototype.getSignatureCount = function(){
	return this.m_signatures.getCount();
}
