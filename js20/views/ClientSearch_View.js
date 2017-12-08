/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 
 * @class
 * @classdesc
 
 * @requires core/extend.js
 * @requires core/View.js
  
 * @param {string} id - html tag id
 * @param {namespace} options
 */
function ClientSearch_View(id,options){
	options = options || {};	
		
	ClientSearch_View.superclass.constructor.call(this,id,options);
	
	var result_model = new ModelXML("SearchResult_Model",{
		//"fields":["name","dirname","dirpost","inn","kpp","ogrn","okpo","okved","status","address"]
		"fields":["param","val"]
	});
	var result_contr = new ClientSearch_Controller();
	this.m_queryMethodField = result_contr.getPublicMethod("search").getField("query");
	
	var self = this;
	this.addElements([
		new EditString(id+":query-str",{
			"maxlength":"250",
			"placeholder":"ИНН или наименование контрагента для поиска",
			"buttonSelect":new ButtonCmd(id+":query-str:submit",{
				"glyph":"glyphicon-search",
				"onClick":function(){
					self.submit();
				}
			}),
			"events":{
				"keydown":function(e){
					e = EventHelper.fixKeyEvent(e);
					if (e.keyCode==13){
						self.submit();
					}				
				}
			}
		}),
		
		new GridAjx(id+":result",{
			"keyIds":["param"],
			"model":result_model,
			"controller":result_contr,
			"readPublicMethod":result_contr.getPublicMethod("search"),
			"editInline":true,
			"editWinClass":null,
			"commands":null,		
			"popUpMenu":null,
			"showHead":false,
			"head":new GridHead(id+"-grid:head",{
				"elements":[
					new GridRow(id+":result:head:row0",{
						"elements":[
							new GridCellHead(id+":result:head:param",{
								"value":"Параметр",
								"columns":[
									new GridColumn({"field":result_model.getField("param")})
								]
							}),
							new GridCellHead(id+":result:head:val",{
								"value":"Значение",
								"columns":[
									new GridColumn({"field":result_model.getField("val")})
								]
							})						
							/*
							new GridCellHead(id+":result:head:name",{
								"value":"Наименование",
								"columns":[
									new GridColumn({"field":result_model.getField("name")})
								]
							}),
							new GridCellHead(id+":result:head:inn",{
								"value":"ИНН",
								"columns":[
									new GridColumn({"field":result_model.getField("inn")})
								]
							}),
							new GridCellHead(id+":result:head:kpp",{
								"value":"КПП",
								"columns":[
									new GridColumn({"field":result_model.getField("kpp")})
								]
							}),
							
							new GridCellHead(id+":result:head:dirname",{
								"value":"ФИО руководителя",
								"columns":[
									new GridColumn({"field":result_model.getField("dirname")})
								]
							}),
							new GridCellHead(id+":result:head:dirpost",{
								"value":"Должность руководителя",
								"columns":[
									new GridColumn({"field":result_model.getField("dirpost")})
								]
							}),
							new GridCellHead(id+":result:head:ogrn",{
								"value":"ОГРН",
								"columns":[
									new GridColumn({"field":result_model.getField("ogrn")})
								]
							}),
							new GridCellHead(id+":result:head:okpo",{
								"value":"ОКПО",
								"columns":[
									new GridColumn({"field":result_model.getField("okpo")})
								]
							}),
							new GridCellHead(id+":result:head:okved",{
								"value":"ОКВЭД",
								"columns":[
									new GridColumn({"field":result_model.getField("okved")})
								]
							}),
							new GridCellHead(id+":result:head:status",{
								"value":"Статус",
								"columns":[
									new GridColumn({"field":result_model.getField("status")})
								]
							}),
							new GridCellHead(id+":result:head:address",{
								"value":"Адрес",
								"columns":[
									new GridColumn({"field":result_model.getField("address")})
								]
							})
							*/
						]
					})
				]
			}),
			"autoRefresh":false,
			"navigate":false,
			"navigateClick":false
		})
	]);	
}
extend(ClientSearch_View,View);

/* Constants */


/* private members */

/* protected*/


/* public methods */

ClientSearch_View.prototype.submit = function(){
	this.m_queryMethodField.setValue(this.getElement("query-str").getValue());
	var self = this;
	this.getElement("result").onRefresh(function(){
		if (self.getElement("result").getModel().getRowCount()){
			self.saveOrg();
		}
	});

}

ClientSearch_View.prototype.saveOrg = function(){
	/*
		Наименование
		ФИО руководителя
		Должность руководителя
		ИНН
		КПП
		ОГРН
		ОКПО
		ОКВЭД
		Дата регистрации
		Адрес
	*/
	var f_vals = {};
	var org_m = this.getElement("result").getModel();
	if (!org_m.getRowCount()){
		throw new Error('Найдите клиента!');
	}
	org_m.reset();
	while (org_m.getNextRow()){
		f_vals[org_m.getFieldValue("param")] = org_m.getFieldValue("val");
	}

	var client_data;
	if (f_vals["ИНН"] && f_vals["ИНН"].length){
		if (f_vals["ИНН"].length==10){
			//ОРГАНИЗАЦИЯ
			client_data = '<ЮрЛицо>'+
			'<ОфициальноеНаименование>'+f_vals["Наименование"]+'</ОфициальноеНаименование>'+
			'<ИНН>'+f_vals["ИНН"]+'</ИНН>'+
			'<КПП>'+f_vals["КПП"]+'</КПП>'+		
			(
				(f_vals["Адрес"]!=undefined && f_vals["Адрес"].length)?
					('<ЮридическийАдрес>'+
						'<Представление>'+f_vals["Адрес"]+'</Представление>'+
					'</ЮридическийАдрес>')
					:''
			)+
			(
				(f_vals["Дата регистрации"]!=undefined && f_vals["Дата регистрации"].length)?
					('<ДатаРегистрации>'+f_vals["Дата регистрации"]+'</ДатаРегистрации>')
					:''	
			)+		
			(
				(f_vals["ОКПО"]!=undefined && f_vals["ОКПО"].length)?
					('<ОКПО>'+f_vals["ОКПО"]+'</ОКПО>')
					:''	
			)+				
			'</ЮрЛицо>';
		}
		else{
			//ИП
			var n = f_vals["Наименование"];
			if (n.substr(0,3)=="ИП "){
				n = n.substr(3);
			}
			var name = n.split(" ",3);
			client_data = '<ФизЛицо>'+
			'<ПолноеНаименование>'+f_vals["Наименование"]+'</ПолноеНаименование>'+
			(
				(name.length)? ('<Фамилия>'+name[0]+'</Фамилия>'):""
			)+
			(
				(name.length>=1)? ('<Имя>'+name[1]+'</Имя>') : ""
			)+
			(
				(name.length>=2)? ('<Отчество>'+name[2]+'</Отчество>'):""
			)+
			'<ИНН>'+f_vals["ИНН"]+'</ИНН>'+
			(
				(f_vals["Адрес"]!=undefined && f_vals["Адрес"].length)?
					('<АдресРегистрации>'+
						'<Представление>'+f_vals["Адрес"]+'</Представление>'+
					'</АдресРегистрации>')
					:''
			)+
			'</ФизЛицо>';
		
		}
	
		/* ФАЙЛ 1с8
		 * ид = 8-4-4-4-12
		 */
		//var str = '﻿<?xml version="1.0" encoding="UTF-8"?>'+
		var str = '<Контрагент xmlns="http://v8.1c.ru/edi/edi_stnd" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="Контрагент">'+
		'<Ид>'+CommonHelper.uniqid()+'</Ид>'+
		'<Наименование>'+f_vals["Наименование"]+'</Наименование>'+
		client_data+
		'</Контрагент>';
	
		var vars = window.getApp().getServVars();
		var pm = (new Agent1c_Controller({
			"servConnector":new ServConnector({
				"host":"http://"+vars.upd1c_server_ip+":"+vars.upd1c_server_port+"/",
				"CORS":true
			})
		})).getPublicMethod("save_org");
		pm.setFieldValue("data",str);
		pm.setFieldValue("file_name","org.xml");
		pm.run({
			//"requestType":"post",
			"ok":function(resp){
				var file_name = "не определен";
				if (resp.modelExists("ResponseData")){
					var m = new ModelObjectXML("ResponseData",{
						"fields":["file_name"],
						"data":resp.getModelData("ResponseData")
					});
					file_name = m.getFieldValue("file_name");
				}
			
				window.showNote("Данные контрагента сохранены в файл:"+file_name);
			}
		});
	}
}

