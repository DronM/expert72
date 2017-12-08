<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="html.xsl"/>

<!-- -->
<xsl:variable name="TEMPLATE_ID" select="'ApplicationDialog'"/>
<!-- -->

<xsl:template match="/">
<div id="{{{{id}}}}" class="panel panel-flat">
	<div class="panel-body dialogForm">
		<div class="tabbable">
			<!--  {{app.COLOR_CLASS}} -->
			<ul class="nav nav-tabs nav-tabs-highlight">				
				<li class="active">
					<a href="#aplication" data-toggle="tab" aria-expanded="true">
						<span id="{{{{id}}}}:fill_percent" class="badge badge-danger" title="Необходимо заполнить заявление на 100%"></span>
						Заявление</a>
				</li>
				<li id="{{{{id}}}}:tab-pd" class=""><a href="#documents_pd" data-toggle="tab" aria-expanded="false">ПД</a></li>
				<li id="{{{{id}}}}:tab-dost" class=""><a href="#documents_dost" data-toggle="tab" aria-expanded="false">Достоверность</a></li>
				<li id="{{{{id}}}}:tab-in_mail" class=""><a href="#in_mail" data-toggle="tab" aria-expanded="false">Входящие письма</a></li>
				<li id="{{{{id}}}}:tab-out_mail" class=""><a href="#in_mail" data-toggle="tab" aria-expanded="false">Исходящие письма</a></li>
			</ul>
			
			<div class="tab-content">
				<div class="tab-pane fade in active" id="aplication">
					<div id="{{{{id}}}}:inf_sent" class="hidden">
					<h5 class="no-margin text-semibold">Заявление отправлено на проверку до <span id="{{{{id}}}}:application_state_end_date" class="label label-primary label-rounded"></span>.</h5>
					<h5 class="no-margin text-semibold">Редактирование запрещено.</h5>
					</div>
					<div id="{{{{id}}}}:inf_filling" class="hidden">
					<h5 class="no-margin text-semibold">Для подачи необходимо заполнить заявление на 100%.</h5>
					<h5 class="no-margin text-semibold">Все поля данных обязательны для заполнения. При отсутствии данных, необходимо указать <u class="text-bold">«Отсутствует»</u> или <u class="text-bold">«Не требуется»</u>, для числовых полей <u class="text-bold">«0»</u>.</h5>
					</div>
					<div id="{{{{id}}}}:inf_closed" class="hidden">
					<h5 class="no-margin text-semibold">Заявление закрыто.</h5>
					</div>
					<div id="{{{{id}}}}:inf_closed_no_expertise" class="hidden">
					<h5 class="no-margin text-semibold">Заявление закрыто без проведения экспертизы.</h5>
					</div>					
					<div id="{{{{id}}}}:inf_returned" class="hidden">
					<h5 class="no-margin text-semibold">Заявление возвращено на доработку.</h5>
					</div>
					<div id="{{{{id}}}}:inf_waiting_for_pay" class="hidden">
					<h5 class="no-margin text-semibold">Ожидание оплаты.</h5>
					</div>
					<div id="{{{{id}}}}:inf_waiting_for_contract" class="hidden">
					<h5 class="no-margin text-semibold">Ожидание подписания контраета.</h5>
					</div>
					
					<h2>Заявление № <u id="{{{{id}}}}:id"/> от <u id="{{{{id}}}}:create_dt"/> </h2>
					
					<div class="tabbable nav-tabs-vertical nav-tabs-left">
						<ul class="nav nav-tabs nav-tabs-highlight">
							<li class="active">
								<a href="#common_inf-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:common_inf-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Общая информация
								</a>
							</li>
							<li>
								<a href="#applicant-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:applicant-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Сведения о заявителе
								</a>
							</li>
							<li>
								<a href="#contractors-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:contractors-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Сведения об исполнителях работ
								</a>
							</li>
							<li>
								<a href="#construction-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:construction-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Сведения об объекте капитального строительства
								</a>
							</li>
							<li>
								<a href="#customer-tab" data-toggle="tab" class="legitRipple">
									<span id="{{{{id}}}}:customer-tab-fill_percent" class="badge badge-danger pull-right" title="Процент заполнения">0%</span>
									Сведения о заказчике
								</a>
							</li>
							
						</ul>

						<div class="tab-content">
							<div class="tab-pane active has-padding" id="common_inf-tab">
								<h3>Общая информация о проекте</h3>
								<div id="{{{{id}}}}:office"/>
								<div id="{{{{id}}}}:expertise_type"/>
								<div id="{{{{id}}}}:estim_cost_type"/>
								<div id="{{{{id}}}}:fund_source"/>
							</div>

							<div class="tab-pane has-padding" id="applicant-tab">
								<div id="{{{{id}}}}:applicant"/>
							</div>
							
							<div class="tab-pane has-padding" id="contractors-tab">
								<h3>Сведения об исполнителях</h3>
								<div class="bg-">Вы можите добавить несколько исполнителей.</div>
								<div id="{{{{id}}}}:contractors"/>
							</div>

							<div class="tab-pane has-padding" id="construction-tab">
								<h3>Сведения об объекте</h3>
								<div id="{{{{id}}}}:constr_name"/>
								<div id="{{{{id}}}}:constr_address"/>
								<div id="{{{{id}}}}:constr_construction_type"/>
								
								<div id="{{{{id}}}}:constr_total_est_cost"/>
								
								<!--
								<div id="{{{{id}}}}:constr_land_area"/>
								<div id="{{{{id}}}}:constr_total_area"/>
								-->
								
								<div class="panel panel-flat">
									<div class="panel-heading">
										<h5 class="panel-title">Технические характеристики объекта</h5>
									</div>
									<div class="panel-body">
										<div id="{{{{id}}}}:constr_technical_features"/>
									</div>	
								</div>
							</div>

							<div class="tab-pane has-padding" id="customer-tab">	
								<div id="{{{{id}}}}:customer"/>
							</div>

						</div>
					</div>				
				</div>
				
				<div class="tab-pane fade" id="documents_pd">
					<div id="{{{{id}}}}:documents_pd"/>
				</div>
				<div class="tab-pane fade" id="documents_dost">
					<div id="{{{{id}}}}:documents_dost"/>
				</div>
				<div class="tab-pane fade" id="in_mail">
					<div id="{{{{id}}}}:in_mail"/>
				</div>
				<div class="tab-pane fade" id="out_mail">
					<div id="{{{{id}}}}:out_mail"/>
				</div>
				
			</div>
		</div>
	</div>
<div id="{{{{id}}}}:cmd-cont">
	<div id="{{{{id}}}}:cmdOk">
	</div>
	<div id="{{{{id}}}}:cmdCancel">
	</div>	
	
	<div id="{{{{id}}}}:cmdPrintApp">
	</div>	

	<div id="{{{{id}}}}:cmdPrintDost">
	</div>	

	<div id="{{{{id}}}}:cmdZipAll">
	</div>	
	
	<div id="{{{{id}}}}:cmdSend">
	</div>	
	
</div>
	
</div>


</xsl:template>

</xsl:stylesheet>
