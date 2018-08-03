<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="html.xsl"/>

<!-- -->
<xsl:variable name="TEMPLATE_ID" select="'ApplicationDialog'"/>
<!-- -->

<xsl:template match="/">
<xsl:comment>
This file is generated from the template build/templates/tmpl/html.xsl
All direct modification will be lost with the next build.
Edit template instead.
</xsl:comment>
<div id="{{{{id}}}}" class="panel panel-flat">
<div id="{{{{id}}}}:cmd-cont">
	<div id="{{{{id}}}}:cmdOk" options="{{'caption':'Записать ','glyph':'glyphicon-ok'}}" title="Записать изменения и закрыть форму заявления">
	</div>
	<div id="{{{{id}}}}:cmdCancel" title="Закрыть форму заявления">
	</div>	
	
	<div id="{{{{id}}}}:cmdZipAll" options="{{'caption':'Скачать документацию ','glyph':'glyphicon-compressed'}}" title="Скачать все документы одним архивом">
	</div>	
	{{#checkSig}}
	<div id="{{{{id}}}}:cmdCheckSig" options="{{'caption':'Проверить подписи ','glyph':'glyphicon-thumbs-up'}}" title="Сформировать отчет о проверке всех ЭЦП заявления">
	</div>	
	{{/checkSig}}
	<div id="{{{{id}}}}:cmdSend" options="{{'caption':'Отправить на проверку ','glyph':'glyphicon-send'}}" title="Отправить заявление с документацией на проверку">
	</div>
	{{#linkedAppExists}}
	<div class="pull-right">Данное заявление подавалось вместе с <a id="{{{{id}}}}:linkedApp" href="#">{{linkedApp}}</a></div>
	{{/linkedAppExists}}
</div>

	<div class="panel-body dialogForm">
		<div class="tabbable">
			<!--  {{app.COLOR_CLASS}} -->
			<ul class="nav nav-tabs nav-tabs-highlight">				
				<li class="active">
					<a href="#aplication" data-toggle="tab" aria-expanded="true">
						<span id="{{{{id}}}}:fill_percent" class="badge badge-danger" title="Необходимо заполнить заявление на 100% и загрузить файлы с документацией"></span>
						Заявление</a>
				</li>
				<li id="{{{{id}}}}:tab-pd" class=""><a href="#documents_pd" data-toggle="tab" aria-expanded="false">ПД</a></li>
				<li id="{{{{id}}}}:tab-eng_survey" class=""><a href="#documents_eng_survey" data-toggle="tab" aria-expanded="false">РИИ</a></li>
				<li id="{{{{id}}}}:tab-cost_eval_validity" class=""><a href="#documents_cost_eval_validity" data-toggle="tab" aria-expanded="false">Достоверность</a></li>
				<li id="{{{{id}}}}:tab-modification" class=""><a href="#documents_modification" data-toggle="tab" aria-expanded="false">Модификация</a></li>
				<li id="{{{{id}}}}:tab-audit" class=""><a href="#documents_audit" data-toggle="tab" aria-expanded="false">Аудит</a></li>
				<li id="{{{{id}}}}:tab-doc_folders" class="hidden"><a href="#doc_folders" data-toggle="tab" aria-expanded="false">Документы</a></li>
				<li id="{{{{id}}}}:tab-doc_flow_in" class="hidden"><a href="#doc_flow_in" data-toggle="tab" aria-expanded="false">Входящие письма</a></li>
				<li id="{{{{id}}}}:tab-doc_flow_out" class="hidden"><a href="#doc_flow_out" data-toggle="tab" aria-expanded="false">Исходящие письма</a></li>				
			</ul>
			
			<div class="tab-content">
				<div class="tab-pane fade in active" id="aplication">
					<div id="{{{{id}}}}:inf_sent" class="hidden appState">
					<h5 class="no-margin text-semibold text-danger">Заявление отправлено на проверку.</h5>
					<h5 class="no-margin text-semibold text-danger">Редактирование запрещено.</h5>
					</div>
					<div id="{{{{id}}}}:inf_checking" class="hidden appState">
					<h5 class="no-margin text-semibold text-danger">Заявление на рассмотрении до <span id="{{{{id}}}}:application_state_end_date_checking" class="label label-primary label-rounded"></span>.</h5>
					<h5 class="no-margin text-semibold text-danger">Редактирование запрещено.</h5>
					</div>					
					<div id="{{{{id}}}}:inf_filling" class="hidden appState">
					<h5 class="no-margin text-semibold">Для подачи необходимо заполнить заявление на 100%.</h5>
					<h5 class="no-margin text-semibold">Все поля, отмеченные звездочкой, обязательны для заполнения.</h5>
					<!--  При отсутствии данных, необходимо указать <u class="text-bold">«Отсутствует»</u> или <u class="text-bold">«Не требуется»</u>, для числовых полей <u class="text-bold">«0»</u>. -->
					</div>
					<div id="{{{{id}}}}:inf_correcting" class="hidden appState">
					<h5 class="no-margin text-semibold">Для подачи необходимо заполнить заявление на 100%.</h5>
					<h5 class="no-margin text-semibold">Все поля, отмеченные звездочкой, обязательны для заполнения.</h5>
					<h5 class="no-margin text-semibold text-danger">Необходимо повторно отправить заявление до <span id="{{{{id}}}}:application_state_end_date_correcting" class="label label-primary label-rounded">.</span>.</h5>
					</div>
					<div id="{{{{id}}}}:inf_closed" class="hidden appState">
					<h5 class="no-margin text-semibold">Отправлено заключение.</h5>
					</div>
					<div id="{{{{id}}}}:inf_closed_no_expertise" class="hidden appState">
					<h5 class="no-margin text-semibold">Заявление закрыто без проведения экспертизы.</h5>
					</div>					
					<div id="{{{{id}}}}:inf_returned" class="hidden appState">
					<h5 class="no-margin text-semibold">Отказ по заявлению. Файлы будут храниться в течении трех месяцев.</h5>
					</div>
					<div id="{{{{id}}}}:inf_waiting_for_pay" class="hidden appState">
					<h5 class="no-margin text-semibold">Ожидание оплаты.</h5>
					</div>
					<div id="{{{{id}}}}:inf_waiting_for_contract" class="hidden appState">
					<h5 class="no-margin text-semibold">Ожидание подписания контракта.</h5>
					</div>
					<div id="{{{{id}}}}:inf_expertise" class="hidden appState">
					<h5 class="no-margin text-semibold">Проведение экспертизы проекта.</h5>
					</div>
										
					{{#contractExists}}					
					<h4>Заключение № <u>{{expertiseResultNumber}}</u>{{#expertiseResultExists}}{{expertiseResultDate}}{{/expertiseResultExists}}</h4>
					<h4>Контракт № <u>{{contractNumber}}</u> от <u>{{contractDate}}</u> </h4>
					<h4>Заявление № <u id="{{{{id}}}}:id"/> от <u id="{{{{id}}}}:create_dt"/> </h4>
					{{/contractExists}}
					
					{{#contractNotExists}}
					<h2>Заявление № <u id="{{{{id}}}}:id"/> от <u id="{{{{id}}}}:create_dt"/> </h2>
					{{/contractNotExists}}
					
					<div class="tabbable nav-tabs-vertical nav-tabs-left">
						<ul class="nav nav-tabs nav-tabs-highlight">
							<li class="active">
								<a href="#common_inf-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:common_inf-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Общая информация
								</a>
							</li>
							<li>
								<a href="#construction-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:construction-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Объект строительства
								</a>
							</li>							
							<li>
								<a href="#applicant-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:applicant-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Заявитель
								</a>
							</li>
							<li>
								<a href="#contractors-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:contractors-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Исполнители работ
								</a>
							</li>
							<li>
								<a href="#customer-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:customer-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Технический заказчик
								</a>
							</li>
							<li>
								<a href="#developer-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:developer-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Застройщик
								</a>
							</li>
							<li>
								<a href="#application_prints-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:application_prints-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Файлы заявлений
								</a>
							</li>
							
							
						</ul>

						<div class="tab-content">
							<div class="tab-pane active has-padding" id="common_inf-tab">
								<h3>Общая информация о проекте</h3>
								<div id="{{{{id}}}}:offices_ref"/>
								<div id="{{{{id}}}}:service_cont"/>
								<div id="{{{{id}}}}:primary_application"/>
								<div id="{{{{id}}}}:fund_sources_ref"/>
							</div>
							<div class="tab-pane has-padding" id="construction-tab">
								<h3>Сведения об объекте</h3>
								<div id="{{{{id}}}}:constr_name"/>
								<div id="{{{{id}}}}:constr_address"/>
								<div id="{{{{id}}}}:construction_types_ref"/>
								<div id="{{{{id}}}}:build_types_ref"/>
								
								<div id="{{{{id}}}}:total_cost_eval"/>
								<div id="{{{{id}}}}:limit_cost_eval"/>
								<div id="{{{{id}}}}:pd_usage_info"/>
								
								<div class="panel panel-flat">
									<div class="panel-heading">
										<h5 class="panel-title">Технические характеристики объекта</h5>
									</div>
									<div class="panel-body">
										<div id="{{{{id}}}}:constr_technical_features"/>
										
										<div class="panel">
											<div class="panel-heading">
												<h6 class="panel-title">Сведения о зданиях, сооружениях, входящих в состав сложного объекта (имущественного комплекса)</h6>
											</div>	
											<div class="panel-body">
												<div id="{{{{id}}}}:constr_technical_features_in_compound_obj"/>
											</div>
										</div>
									</div>	
								</div>
							</div>

							<div class="tab-pane has-padding" id="applicant-tab">
								<div id="{{{{id}}}}:applicant"/>
							</div>
							
							<div class="tab-pane has-padding" id="contractors-tab">
								<h3>Сведения об исполнителях</h3>
								<div class="bg-">Вы можите добавить несколько исполнителей.</div>
								<div id="{{{{id}}}}:contractors"/>
							</div>


							<div class="tab-pane has-padding" id="customer-tab">	
								<div id="{{{{id}}}}:customer"/>
							</div>

							<div class="tab-pane has-padding" id="developer-tab">	
								<div id="{{{{id}}}}:developer"/>
							</div>

							<div class="tab-pane has-padding" id="application_prints-tab">	
								<h3>Файлы заявлений</h3>
								<h4>Рапечатайте заполненный бланк заявления, подпишите ЭЦП, загрузите бланк заявления (pdf) и подписанный бланк (sig)</h4>
								<div id="{{{{id}}}}:app_print_expertise"/>
								<div id="{{{{id}}}}:app_print_cost_eval"/>
								<div id="{{{{id}}}}:app_print_modification"/>
								<div id="{{{{id}}}}:app_print_audit"/>
							</div>

						</div>
					</div>				
				</div>
				
				<div class="tab-pane fade" id="documents_pd">
					<div id="{{{{id}}}}:documents_pd"/>
				</div>
				<div class="tab-pane fade" id="documents_eng_survey">
					<div id="{{{{id}}}}:documents_eng_survey"/>
				</div>
				<div class="tab-pane fade" id="documents_cost_eval_validity">
					<div id="{{{{id}}}}:documents_cost_eval_validity"/>
				</div>
				<div class="tab-pane fade" id="documents_modification">
					<div id="{{{{id}}}}:documents_modification"/>
				</div>
				<div class="tab-pane fade" id="documents_audit">
					<div id="{{{{id}}}}:documents_audit"/>
				</div>
				<div class="tab-pane fade" id="doc_folders">
					<div id="{{{{id}}}}:doc_folders"/>
				</div>
				
				<div class="tab-pane fade" id="doc_flow_in">
					<div id="{{{{id}}}}:doc_flow_in"/>
				</div>
				<div class="tab-pane fade" id="doc_flow_out">
					<div id="{{{{id}}}}:doc_flow_out"/>
				</div>
				
			</div>
		</div>
	</div>
	
	{{#is_admin}}
	<div id="{{{{id}}}}:users_ref"/>
	{{/is_admin}}
	
</div>


</xsl:template>

</xsl:stylesheet>
