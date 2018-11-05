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
 * @param {int} options.maxSignatureCount 
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
	this.m_maxSignatureCount = options.maxSignatureCount;
	
	this.m_readOnly = (options.readOnly!=undefined)? options.readOnly : false;
	
	this.m_signatures = new ControlContainer(id+":sigs","SPAN");
	if (options.signatures){
		for(var i=0;i<options.signatures.length;i++){
			this.addSignature(options.signatures[i]);
		}
	}
	
	this.m_onGetSignatureDetails = options.onGetSignatureDetails;
	this.m_onGetFileUploaded = options.onGetFileUploaded;
	
	FileSigContainer.superclass.constructor.call(this,id,"SPAN",options);		
}
//ViewObjectAjx,ViewAjxList
extend(FileSigContainer,Control);

/* Constants */
FileSigContainer.prototype.IMG_WAIT = "fa fa-spinner fa-spin";
FileSigContainer.prototype.IMG_KEY = "icon-key";
FileSigContainer.prototype.ADD_SIG_TITLE = "Подписать файл выбранной подписью";
FileSigContainer.prototype.SIG_PROCESS_TITLE = "Подписать файл выбранной подписью";
FileSigContainer.prototype.SIG_ERR_CLASS = "border-danger";

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
	
	var self = this;
	
	//this.m_signatures.getId()+":"+signature.id
	var sig_ind = this.m_signatures.getCount()+1;
	var ctrl = new ControlContainer(this.m_signatures.getId()+":"+sig_ind,"SPAN",{
		"className": ("btn btn-sm fileSigInfoBtn" + ((signature&&(signature.check_result||signature.check_result==undefined))? "":(" "+this.SIG_ERR_CLASS)) ),
		"events":{
			"click":function(e){
				if (self.m_onSignClick){
					self.m_onSignClick(self.m_fileId,self.m_itemId);
				}
			}
		}
	});
	ctrl.setValid = function(v){
		if (v){
			DOMHelper.delClass(this.m_node,self.SIG_ERR_CLASS);
		}
		else{
			DOMHelper.addClass(this.m_node,self.SIG_ERR_CLASS);
		}
	}
	
	/**
	 * Есть свойство this.certInf.signature содержащее структуру подписи
	 */
	ctrl.getCertOwnerDescr = function(callBack){
		var res = "<не определен>";
		var sig = this.certInf.signature;
		if (sig){			
			var cert_self = this;
			if(sig.check_result==undefined && !sig.owner && self.m_onGetSignatureDetails && self.m_onGetFileUploaded(self.m_fileId,self.m_itemId)){
				self.m_onGetSignatureDetails(self.m_fileId,function(signature){
					cert_self.certInf.signature = signature;
					cert_self.getCertOwnerDescrCont(callBack);
				});
			}
			else{
				this.getCertOwnerDescrCont(callBack);
			}
		}
		return res;	
	}
	ctrl.getCertOwnerDescrCont = function(callBack){
		var sig = this.certInf.signature;
		var res = "";
		if (sig.owner && sig.owner["Фамилия"]){
			res = this.certInf.signature.owner["Фамилия"];
		}
		if (sig.owner && sig.owner["Имя"]){
			res+= res? " ":"";
			res+= this.certInf.signature.owner["Имя"];
		}
		callBack(res);	
	}
		
	ctrl.certInf = new ToolTip({
		"wait":300,
		"onHover":function(e){
			if (this.signature){
				if(this.signature.check_result==undefined && !this.signature.owner && self.m_onGetSignatureDetails && self.m_onGetFileUploaded(self.m_fileId,self.m_itemId)){
					//server call
					var tool_tip = this;
					self.m_onGetSignatureDetails(self.m_fileId,function(signature){
						tool_tip.signature = signature;
						self.showSignatureDetails(tool_tip,e);
					});
				}
				else{
					self.showSignatureDetails(this,e);
				}
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
			var vs= (
				(!this.m_maxSignatureCount || sig_cnt<this.m_maxSignatureCount)
				&& ( cert_cnt && (!sig_cnt || this.m_multiSignature) )
			);
			var self = this;
			
			/* if there is no class fileSignNoSig
			 * there will never be any possibility to apply signature (no key button) 
			 */
			this.m_addSignControl = new ControlContainer(this.getId()+":addSign","SPAN",{
				"className":"btn btn-sm"+(
					((sig_cnt>=this.m_maxSignatureCount)||(this.m_signatures.getCount()&&!this.m_multiSignature))? "":" fileSignNoSig"
					),
				"title":this.ADD_SIG_TITLE,
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

FileSigContainer.prototype.setAddSignVisible = function(v){
	if (this.m_addSignControl)this.m_addSignControl.setVisible(v);
}


FileSigContainer.prototype.setWait = function(v){
	if (this.m_addSignControl){
		//console.log("FileSigContainer.prototype.setWait="+v)
		//this.m_addSignControl.getElement("pic").setClassName( (v? this.IMG_WAIT:this.IMG_KEY) );
		this.m_addSignControl.getElement("pic").setAttr("class",(v? this.IMG_WAIT:this.IMG_KEY));
		this.m_addSignControl.setAttr("title", (v? this.SIG_PROCESS_TITLE:this.ADD_SIG_TITLE) );
	}	
}

FileSigContainer.prototype.setAddSigEnabled = function(v){
	if (this.m_addSignControl){
		this.m_addSignControl.setEnabled(v);
	}	
}

FileSigContainer.prototype.getSignatureCount = function(){
	return this.m_signatures.getCount();
}

FileSigContainer.prototype.getSignatures = function(){
	return this.m_signatures;
}

FileSigContainer.prototype.showSignatureDetails = function(toolTip,e){
	var signature = toolTip.signature;
	
	var add_field = function(field,str,sep,bld){
		sep = sep? sep:", ";
		if (field){
			str+= str.length? sep:"<div>";
			str+= (bld? ("<strong>"+field+"</strong>") : field);
		}
		return str;
	}
	var cont;
	if (signature.check_result!=undefined && signature.owner){				
		//Подпись проверена - ОК
		var sign_date_time_s;
		if (signature.sign_date_time){
			sign_date_time_d = (typeof(signature.sign_date_time)=="string")?
				DateHelper.strtotime(signature.sign_date_time) : signature.sign_date_time;
		}
		var org="";
		var pers="";
		if (signature.owner){
			org=add_field(signature.owner["ИНН"],org);
			org=add_field(signature.owner["ОГРН"],org);
			org=add_field(signature.owner["Организация"],org);				
			org+= org.length? "</div>":"";
		
			pers=add_field(signature.owner["Фамилия"],pers,null,true);
			pers=add_field(signature.owner["Имя"],pers," ",true);
			pers=add_field(signature.owner["Должность"],pers);
			pers=add_field(signature.owner["СНИЛС"],pers);
			pers=add_field(signature.owner["Адрес"],pers);				
			pers=add_field(signature.owner["Эл.почта"],pers);
			pers+= pers.length? "</div>":"";
		}
		var cert = "";
		if (signature.cert_from && signature.cert_to){
			var expir = "";
			if (signature.cert_to&&DateHelper.strtotime(signature.cert_to)<DateHelper.time()){
				expir = '<div class="badge badge-danger">Просрочена</div>';
			}
			cert = "<div>Сертификат с "+DateHelper.format(DateHelper.strtotime(signature.cert_from),"d/m/Y")+" до "+DateHelper.format(DateHelper.strtotime(signature.cert_to),"d/m/Y")+
					expir+
			"</div>";
		}
	
		var check_res = "";
		if (signature.check_result){
			check_res = 
			'<div>'+
				'<i class="glyphicon glyphicon-ok"></i>'+
				' <strong>Подпись проверена</strong>'+
			'</div>';			
		}
		else{
			check_res = 
			'<div>'+
				'<i class="glyphicon glyphicon-remove"></i>'+
				' <strong>Ошибка проверки подписи</strong>'+
				(signature.error_str? "<div>"+signature.error_str+"</div>" : "")+
			'</div>';					
		}
		
		cont ='<div>' +
			check_res+
			(org.length? org:"") +
			(pers.length? pers:"") +
			(signature.sign_date_time? "<div><strong>Подписан: "+DateHelper.format(sign_date_time_d,"d/m/Y H:i")+"</strong></div>":"")+
			cert+						
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
		//Подпись проверена - ОШИБКА и нет сертификатов
		cont ='<div>' +
			'<i class="glyphicon glyphicon-remove"></i>'+
			' <strong>Ошибка проверки подписи</strong>'+
			(signature.error_str? "<div>"+signature.error_str+"</div>" : "")+
		"</div>";

	}					
	toolTip.popup(cont,{"event":e,"width":800});

}

FileSigContainer.prototype.deleteLast = function(){
	var cnt = this.m_signatures.getCount();
	if (cnt){
		this.m_signatures.delElement(cnt);	
		return true;
	}
}
FileSigContainer.prototype.findSignatureBySNILS = function(SNILS){
	var res = false;
	var elem = this.m_signatures.getElements();
	for(var sig_id in elem){
		if (elem[sig_id] && elem[sig_id].certInf.signature&&elem[sig_id].certInf.signature.owner&&elem[sig_id].certInf.signature.owner["СНИЛС"]==SNILS){
			res = true;
			break;
		}
	}
	return res;
}

FileSigContainer.prototype.setMaxSignatureCount = function(v){
	this.m_maxSignatureCount = v;
}

