/* Copyright (c) 2017
	Andrey Mikhalevich, Katren ltd.

This file is created automaticaly during build process
DO NOT MODIFY IT!!!	
*/
		App.prototype.m_templates = {"GridCmdContainerAjx":"<div id=\"{{id}}\">\n\t	{{#this.getCmdInsert()}}\n\t	<div id=\"{{id}}:insert\"></div>	\n\t	{{/this.getCmdInsert()}}\n\t	\n\t	{{#this.getCmdSearch()}}\n\t	<div class=\"btn-group\">\n\t		<div id=\"{{id}}:search:set\"></div>\n\t		<div id=\"{{id}}:search:unset\"></div>\n\t	</div>\n\t	{{/this.getCmdSearch()}}\n\t	\n\t	{{#this.getCmdFilter()}}\n\t	<div id=\"{{id}}:filter\"></div>\n\t	{{/this.getCmdFilter()}}\n\t		\n\t	{{#this.getCmdPrintObj()}}\n\t	<div id=\"{{id}}:printObj\"></div>\n\t	{{/this.getCmdPrintObj()}}\n\t		\n\t	{{#this.getCmdAllCommands()}}\n\t	<div id=\"{{id}}:allCommands\"></div>\n\t	{{/this.getCmdAllCommands()}}\n\t</div>\n\t","ViewGridColManager":"<div id=\"{{id}}\">\n\t	<div class=\"form-group {{window.getBsCol(12)}}\">\n\t		<div id=\"{{id}}:save\"></div>\n\t		<div id=\"{{id}}:open\"></div>\n\t	</div>\n\t\n\t	<ul class=\"nav nav-tabs\" role=\"tablist\">\n\t	    <li role=\"presentation\" class=\"active\"><a href=\"#columns\" aria-controls=\"columns\" role=\"tab\" data-toggle=\"tab\">{{this.TAB_COLUMNS}}</a></li>\n\t	    <li role=\"presentation\"><a href=\"#sortings\" aria-controls=\"sortings\" role=\"tab\" data-toggle=\"tab\">{{this.TAB_SORT}}</a></li>\n\t	    <!--<li role=\"presentation\"><a href=\"#filters\" aria-controls=\"filters\" role=\"tab\" data-toggle=\"tab\">{{this.TAB_FILTER}}</a></li>-->\n\t	</ul>\n\t\n\t	<!-- Tab panes -->\n\t	<div class=\"tab-content\">	\n\t		<div role=\"tabpanel\" class=\"tab-pane active\" id=\"columns\">\n\t			<div class=\"panel panel-body\">\n\t				<div id=\"{{id}}:view-visibility\"></div>\n\t			</div>\n\t		</div>\n\t\n\t		<div role=\"tabpanel\" class=\"tab-pane\" id=\"sortings\">\n\t			<div class=\"panel panel-body\">\n\t				<div id=\"{{id}}:view-order\"></div>\n\t			</div>\n\t		</div>\n\t<!--	\n\t		<div role=\"tabpanel\" class=\"tab-pane\" id=\"filters\">\n\t			<div class=\"panel panel-body\">\n\t				<div id=\"{{id}}:view-filter\"></div>\n\t			</div>\n\t		</div>\n\t-->\n\t</div>\n\t\n\t","PopOver":"<div id=\"{{id}}\" class=\"popover\" role=\"tooltip\" style=\"position:absolute;display:block;max-width:100%;\">\n\t	<div class=\"tooltip-arrow\"></div>\n\t	<h3 id=\"{{id}}:title\" class=\"popover-title\"></h3>\n\t	<div id=\"{{id}}:content\" class=\"popover-content\"></div>\n\t</div>\n\t","GridCmdFilterView":"<form id=\"{{id}}\" class=\"form-horizontal\">\n\t	<div class=\"form-group {{window.getBsCol(12)}}\">\n\t		<div id=\"{{id}}:set\"></div>\n\t		<div id=\"{{id}}:unset\"></div>\n\t		<div id=\"{{id}}:save\"></div>\n\t		<div id=\"{{id}}:open\"></div>\n\t	</div>\n\t</form>\n\t","EditPeriodDate":"<div id=\"{{id}}\" class=\"form-group {{bsCol}}12\">\n\t	<a class=\"{{bsCol}}1\" id=\"{{id}}:periodSelect\"></a>	\n\t	\n\t	<div class=\"btn-group {{bsCol}}2\">\n\t		<div id=\"{{id}}:downFast\" title=\"{{CONTR_DOWN_FAST_TITLE}}\"></div>\n\t		<div id=\"{{id}}:down\" title=\"{{CONTR_DOWN_TITLE}}\"></div>\n\t	</div>\n\t	\n\t	<div id=\"{{id}}:d-cont\" class=\"{{bsCol}}7\" style=\"padding-right:0px;padding-left:0px;\">\n\t		<div id=\"{{id}}:from\" class=\"{{bsCol}}6\" style=\"padding:0px 20px 0px 0px;\"></div>\n\t		<!--<span class=\"{{bsCol}}1\" style=\"padding-left:0px;padding-right:0px\">-</span>-->\n\t		<div id=\"{{id}}:to\" class=\"{{bsCol}}6\" style=\"padding:0px 0px;margin:0px 0px;\"></div>	\n\t	</div>\n\t	\n\t	<div class=\"btn-group {{bsCol}}2\">\n\t		<div id=\"{{id}}:upFast\" title=\"{{CONTR_UP_FAST_TITLE}}\"></div>\n\t		<div id=\"{{id}}:up\" title=\"{{CONTR_UP_TITLE}}\"></div>\n\t	</div>\n\t	\n\t</div>\n\t","WindowPrint":"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n\t<html>\n\t	<head>\n\t		<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\">\n\t		<link rel=\"stylesheet\" href=\"js20/custom-css/print.css?'+{{scriptId}}+'\" type=\"text/css\" media=\"all\">\n\t		<title>{{title}}</title>\n\t	</head>\n\t	<body>{{content}}</body>\n\t</html>\n\t\n\t","VariantStorageSaveView":"<div id=\"{{id}}\">\n\t	<div id=\"{{id}}:variants\"></div>\n\t	<div id=\"{{id}}:name\"></div>\n\t	<div id=\"{{id}}:default_variant\"></div>\n\t	<div id=\"{{id}}:cmdSave\"></div>\n\t	<div id=\"{{id}}:cmdCancel\"></div>\n\t</div>\n\t","VariantStorageOpenView":"<div id=\"{{id}}\">\n\t	<div id=\"{{id}}:variants\"></div>\n\t	<div id=\"{{id}}:cmdOpen\"></div>\n\t	<div id=\"{{id}}:cmdCancel\"></div>\n\t</div>\n\t","BigFileUploader":"<div id=\"{{id}}\" class=\"panel panel-default\">\n\t	<div class=\"panel panel-body\">\n\t		<div class=\"row\">\n\t			<div id=\"{{id}}:file-add\"> </div>\n\t			<div id=\"{{id}}:file-upload\"> </div>\n\t			<div id=\"{{id}}:file-pause\"> </div>\n\t			<div id=\"{{id}}:file-cancel\"> </div>\n\t		</div>\n\t		<div class=\"row\">\n\t			<div class=\"progress hide\" id=\"upload-progress\">\n\t				<div class=\"progress-bar progress-bar-success progress-bar-striped active\" role=\"progressbar\" aria-valuenow=\"0\"\n\t				aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width:0%\">\n\t				</div>\n\t			</div> 		\n\t		</div>		\n\t		\n\t		<div class=\"row\" id=\"{{id}}:file-list\"/>\n\t	</div>\n\t</div>\n\t","ViewKladr":"<div id=\"{{id}}\">\n\t	<div id=\"{{id}}:region\" autofocus=\"true\"></div>\n\t	<div id=\"{{id}}:raion\"></div>\n\t	<div id=\"{{id}}:naspunkt\"></div>\n\t	<div id=\"{{id}}:gorod\"></div>\n\t	<div id=\"{{id}}:ulitsa\"></div>\n\t	\n\t	<div id=\"{{id}}:dom\"></div>\n\t	<div id=\"{{id}}:korpus\"></div>\n\t	<div id=\"{{id}}:kvartira\"></div>\n\t\n\t</div>\n\t","Captcha":"<div id=\"{{id}}\">\n\t	<div class=\"text-center\">\n\t		<button id=\"{{id}}:refresh\" glyph=\"glyphicon-refresh\" title=\"Обновить\">\n\t		</button>\n\t		\n\t		<img id=\"{{id}}:img\">\n\t		</img>\n\t	</div>\n\t	<div class=\"form-group has-feedback has-feedback-left\">\n\t		<input id=\"{{id}}:key\" type=\"text\" class=\"form-control\" style=\"width:100%;\" placeholder=\"Код с картинки\" title=\"Введите код с картинки\"></input>\n\t		<div class=\"form-control-feedback\"><i class=\"icon-alert text-muted\"></i></div>	\n\t		<span class=\"help-block text-danger hidden\" id=\"{{id}}:error\" name=\"error\">\n\t			<i class=\"icon-cancel-circle2 position-left\"></i>\n\t		</span>		\n\t	</div>\n\t</div>\n\t","ErrorControl":"<span class=\"help-block text-danger\">\n\t	<i class=\"icon-cancel-circle2 position-left\">\n\t	</i>\n\t</span>\n\t","ApplicationClientTab":"<div id=\"{{id}}\">	\n\t	<div class=\"dropdown\">\n\t		<h3 class=\"app-client-header\">\n\t		{{#isCustomer}}Заказчик{{/isCustomer}}\n\t		{{#isApplicant}}Заявитель{{/isApplicant}}  </h3>\n\t		{{#isClient}}\n\t		<button class=\"btn {{colorClass}} dropdown-toggle fillClientData\" type=\"button\" data-toggle=\"dropdown\">Заполнить\n\t			<span class=\"caret\"></span>\n\t		</button>\n\t		<ul class=\"dropdown-menu\" title=\"Зполнить по другим данным\">\n\t			{{#isCustomer}}\n\t			<li><a id=\"{{id}}:fillOnApplicant\" href=\"#\">По заявителю</a></li>\n\t			<li><a id=\"{{id}}:fillOnContractor\" href=\"#\">По исполнителю</a></li>			\n\t			{{/isCustomer}}\n\t			{{#isApplicant}}\n\t			<li><a id=\"{{id}}:fillOnCustomer\" href=\"#\">По заказчику</a></li>\n\t			<li><a id=\"{{id}}:fillOnContractor\" href=\"#\">По исполнителю</a></li>			\n\t			{{/isApplicant}}			\n\t			<li><a id=\"{{id}}:fillOnClientList\" href=\"#\">Выбрать из списка клиентов</a></li>\n\t		</ul>\n\t		{{/isClient}}\n\t	</div> 	\n\t	<div id=\"{{id}}:client_type\">\n\t	</div>\n\t	<div id=\"{{id}}:name\">\n\t	</div>\n\t	<div id=\"{{id}}:name_full\">\n\t	</div>\n\t	\n\t	<div id=\"{{id}}:inn\">\n\t	</div>\n\t	<div id=\"{{id}}:kpp\">\n\t	</div>\n\t	\n\t	<div id=\"{{id}}:ogrn\">\n\t	</div>\n\t	\n\t	<div id=\"{{id}}:person_id_paper\">\n\t	</div>\n\t\n\t	<div id=\"{{id}}:person_registr_paper\">\n\t	</div>\n\t\n\t	<div id=\"{{id}}:legal_address\">\n\t	</div>\n\t\n\t	<div id=\"{{id}}:post_address\">\n\t	</div>\n\t\n\t	<div id=\"{{id}}:responsable_person_head\">\n\t	</div>\n\t\n\t	<div id=\"{{id}}:base_document_for_contract\">\n\t	</div>\n\t\n\t	<div id=\"{{id}}:bank\">\n\t	</div>\n\t\n\t	<div class=\"panel panel-flat\">\n\t		<div class=\"panel-heading\">\n\t			<h5 class=\"panel-title\">Прочие контакты</h5>\n\t		</div>\n\t		<div class=\"panel-body\">\n\t			<div id=\"{{id}}:responsable_persons\">\n\t			</div>\n\t		</div>	\n\t	</div>\n\t	\n\t</div>\n\t","ApplicationContractor":"<div id=\"{{id}} class=\"panel panel-info\">\n\t	<div class=\"panel-heading\">\n\t		<h6 class=\"panel-title\"><span class=\"text-semibold\">Исполнитель {{IND}}</span>\n\t		<a class=\"heading-elements-toggle\"><i class=\"icon-more\"></i></a></h6>		\n\t		<div class=\"heading-elements\">\n\t			<ul class=\"icons-list\">\n\t				<li><a id=\"{{id}}:cmdToggle\" data-action=\"collapse\" class=\"\"></a></li>\n\t				{{#isClient}}\n\t				<li><a id=\"{{id}}:cmdClose\" data-action=\"close\"></a></li>\n\t				{{/isClient}}\n\t			</ul>\n\t		</div>\n\t	</div>\n\t	\n\t	<div class=\"panel-body\" style=\"display: block;\">	\n\t		<div class=\"dropdown\">\n\t			{{#isClient}}\n\t			<button class=\"btn {{colorClass}} dropdown-toggle fillClientData\" type=\"button\" data-toggle=\"dropdown\">Заполнить\n\t				<span class=\"caret\"></span>\n\t			</button>\n\t			<ul class=\"dropdown-menu\" title=\"Зполнить по другим данным\">\n\t				<li><a id=\"{{id}}:fillOnCustomer\" href=\"#\">По заказчику</a></li>\n\t				<li><a id=\"{{id}}:fillOnApplicant\" href=\"#\">По заявителю</a></li>			\n\t				<li><a id=\"{{id}}:fillOnClientList\" href=\"#\">Выбрать из списка клиентов</a></li>\n\t			</ul>\n\t			{{/isClient}}\n\t		</div> \n\t	\n\t		<div id=\"{{id}}:client_type\">\n\t		</div>\n\t		<div id=\"{{id}}:name\">\n\t		</div>\n\t		<div id=\"{{id}}:name_full\">\n\t		</div>\n\t	\n\t		<div id=\"{{id}}:inn\">\n\t		</div>\n\t		<div id=\"{{id}}:kpp\">\n\t		</div>\n\t	\n\t		<div id=\"{{id}}:ogrn\">\n\t		</div>\n\t	\n\t		<div id=\"{{id}}:person_id_paper\">\n\t		</div>\n\t\n\t		<div id=\"{{id}}:person_registr_paper\">\n\t		</div>\n\t\n\t		<div id=\"{{id}}:legal_address\">\n\t		</div>\n\t\n\t		<div id=\"{{id}}:post_address\">\n\t		</div>\n\t\n\t		<div id=\"{{id}}:responsable_person_head\">\n\t		</div>\n\t\n\t		<div id=\"{{id}}:base_document_for_contract\">\n\t		</div>\n\t\n\t		<div id=\"{{id}}:bank\">\n\t		</div>\n\t\n\t		<div class=\"panel panel-flat\">\n\t			<div class=\"panel-heading\">\n\t				<h5 class=\"panel-title\">Прочие контакты</h5>\n\t			</div>\n\t			<div class=\"panel-body\">\n\t				<div id=\"{{id}}:responsable_persons\">\n\t				</div>\n\t			</div>	\n\t		</div>\n\t	\n\t	</div>\n\t</div>\n\t\n\t","EditArea":"<div id=\"{{id}}\">\n\t	<div class=\"row\">\n\t		<div class=\"col-lg-6\">\n\t			<div id=\"{{id}}:val\">\n\t			</div>\n\t		</div>\n\t		<div class=\"col-lg-6\">\n\t			<div id=\"{{id}}:unit\">\n\t			</div>\n\t		</div>\n\t	</div>\n\t</div>\n\t","ApplicationDocuments":"<div id=\"{{id}}\">\n\t	<p>Электронные документы на государственную экспертизу представляются в следующих форматах: {{#allowedFileExt}}<mark>{{ext}}</mark>{{/allowedFileExt}}</p>\n\t	<p>Максимальный размер файла для загрузки:<mark>{{maxFileSize}}</mark></p>\n\t	<p>Добавьте файлы в нужные разделы, затем загрузите.</p>\n\t	\n\t	<div id=\"upload-container\">\n\t		<div id=\"{{id}}:file-upload_{{docType}}\" class=\"btn {{COLOR_CLASS}}\" type=\"button\">Загрузить все файлы  <span id=\"total_upload_files-{{docType}}\" class=\"badge badge-danger\">0</span></div>\n\t	\n\t		<div class=\"progress hide\" id=\"upload-progress-{{docType}}\">\n\t			<div class=\"progress-bar progress-bar-success\" role=\"progressbar\"\n\t			aria-valuenow=\"0\" aria-valuemin=\"0\" aria-valuemax=\"100\" style=\"width:0%\">\n\t				<span id=\"upload-progress-val-{{docType}}\"></span>\n\t			</div>\n\t		</div> 		\n\t	</div>	\n\t	\n\t	<div class=\"panel-group panel-group-control content-group-lg\">	\n\t		{{#items}}\n\t		<div class=\"panel\">\n\t			<div class=\"panel-heading bg-info\">\n\t				<h6 class=\"panel-title\">\n\t					<a data-toggle=\"collapse\" href=\"#collapsible-control-group_{{docType}}_{{item_id}}\" aria-expanded=\"false\" class=\"collapsed file_section\">\n\t					{{#no_items}}<span id=\"{{id}}:total_item_files_{{docType}}_{{item_id}}\" class=\"badge badge-danger\">{{files.length}}</span>{{/no_items}} {{item_descr}}</a>\n\t				</h6>\n\t			</div>\n\t			<div id=\"collapsible-control-group_{{docType}}_{{item_id}}\" class=\"panel-collapse collapse\" aria-expanded=\"false\" style=\"height: 0px;\">\n\t				<div class=\"panel-body\">				\n\t					{{#no_items}}\n\t					<div class=\"resumable-{{docType}}-file-list\" item_id=\"{{item_id}}\">						\n\t						<div id=\"{{id}}:file-add_{{docType}}_{{item_id}}\" class=\"resumable-{{docType}}-file-add btn btn-sm\" title=\"Добавить файл к данному разделу\">\n\t						</div>\n\t						<span class=\"text-thin\">Добавьте файлы кнопкой или перетаскиванием в эту область</span>\n\t					\n\t						<ul id=\"{{id}}:file-list_{{docType}}_{{item_id}}\">\n\t						{{#files}}\n\t							<li id=\"{{id}}:file_{{file_id}}\">\n\t							</li>\n\t						{{/files}}\n\t						</ul>\n\t					</div>					\n\t					{{/no_items}}\n\t					{{#items}}\n\t					<div class=\"panel-group panel-group-control panel-group-control-right content-group-sm\">\n\t						<div class=\"panel panel-white\">\n\t							<div class=\"panel-heading\">\n\t								<h6 class=\"panel-title\">\n\t									<a class=\"collapsed\" data-toggle=\"collapse\" href=\"#collapsible-control-right-group-{{docType}}-{{item_id}}\" aria-expanded=\"false\" class=\"file_section\">\n\t										<span id=\"{{id}}:total_item_files_{{docType}}_{{item_id}}\" class=\"badge badge-danger\">{{files.length}}</span> {{item_descr}}\n\t									</a>\n\t								</h6>\n\t							</div>\n\t							<div id=\"collapsible-control-right-group-{{docType}}-{{item_id}}\" class=\"panel-collapse collapse\" aria-expanded=\"false\" style=\"height: 0px;\">\n\t								<div class=\"panel-body\">\n\t									<div class=\"resumable-{{docType}}-file-list\" item_id=\"{{item_id}}\">\n\t										<div id=\"{{id}}:file-add_{{docType}}_{{item_id}}\" class=\"resumable-{{docType}}-file-add btn btn-sm\" title=\"Добавить файл к данному разделу\">\n\t										</div>\n\t										<span class=\"text-thin\">Добавьте файлы кнопкой или перетаскиванием в эту область</span>\n\t									\n\t										<ul id=\"{{id}}:file-list_{{docType}}_{{item_id}}\">\n\t										{{#files}}\n\t											<li id=\"{{id}}:file_{{file_id}}\">\n\t											</li>										\n\t										{{/files}}\n\t										</ul>\n\t									</div>					\n\t								</div>\n\t							</div>\n\t						</div>\n\t					</div>	\n\t					{{/items}}			\n\t				</div>\n\t			</div>\n\t		</div>\n\t		{{/items}}\n\t	</div>\n\t</div>	\n\t","ApplicationDocumentsForEmploye":"<div id=\"{{id}}\">\n\t	<div class=\"panel-group panel-group-control content-group-lg\">	\n\t		{{#items}}\n\t		<div class=\"panel\">\n\t			<div class=\"panel-heading bg-info\">\n\t				<h6 class=\"panel-title\">\n\t					<a data-toggle=\"collapse\" href=\"#collapsible-control-group{{item_id}}\" aria-expanded=\"false\" class=\"collapsed\">\n\t					{{#no_items}}<span id=\"total_item_files_{{item_id}}\" class=\"badge badge-danger\">{{files.length}}</span>{{/no_items}} {{item_descr}}</a>\n\t				</h6>\n\t			</div>\n\t			<div id=\"collapsible-control-group{{item_id}}\" class=\"panel-collapse collapse\" aria-expanded=\"false\" style=\"height: 0px;\">\n\t				<div class=\"panel-body\">				\n\t					{{#no_items}}\n\t					<div class=\"resumable-file-list\" item_id=\"{{item_id}}\">						\n\t						<ul id=\"file-list-{{docType}}_{{item_id}}\">\n\t						{{#files}}\n\t							<li id=\"{{id}}:file_{{file_id}}\">\n\t							</li>\n\t						{{/files}}\n\t						</ul>\n\t					</div>					\n\t					{{/no_items}}\n\t					{{#items}}\n\t					<div class=\"panel-group panel-group-control panel-group-control-right content-group-sm\">\n\t						<div class=\"panel panel-white\">\n\t							<div class=\"panel-heading\">\n\t								<h6 class=\"panel-title\">\n\t									<a class=\"collapsed\" data-toggle=\"collapse\" href=\"#collapsible-control-right-group{{item_id}}\" aria-expanded=\"false\">\n\t									<span id=\"total_item_files_{{item_id}}\" class=\"badge badge-danger\">{{files.length}}</span> {{item_descr}}</a>\n\t								</h6>\n\t							</div>\n\t							<div id=\"collapsible-control-right-group{{item_id}}\" class=\"panel-collapse collapse\" aria-expanded=\"false\" style=\"height: 0px;\">\n\t								<div class=\"panel-body\">\n\t									<div class=\"resumable-file-list\" item_id=\"{{item_id}}\">\n\t										<ul id=\"file-list-{{docType}}_{{item_id}}\">\n\t										{{#files}}\n\t											<li id=\"{{id}}:file_{{file_id}}\">\n\t											</li>										\n\t										{{/files}}\n\t										</ul>\n\t									</div>					\n\t								</div>\n\t							</div>\n\t						</div>\n\t					</div>	\n\t					{{/items}}			\n\t				</div>\n\t			</div>\n\t		</div>\n\t		{{/items}}\n\t	</div>\n\t</div>	\n\t","ApplicationFile":"<li id=\"{{id}}\" {{#file_uploaded}}uploaded=\"true\"{{/file_uploaded}} file_id=\"{{file_id}}\" file_name=\"{{file_name}}\">\n\t	{{#file_not_deleted}}\n\t		{{#file_uploaded}}\n\t		<i class=\"glyphicon glyphicon-ok\" title=\"Файл загружен на сервер\"></i>	\n\t		{{/file_uploaded}}\n\t		{{#file_not_uploaded}}\n\t		<i class=\"file-pic-{{docType}} glyphicon glyphicon-cloud-upload\" title=\"Необходимо загрузить файл!\"></i>\n\t		{{/file_not_uploaded}}\n\t	{{/file_not_deleted}}\n\t	{{#file_deleted}}\n\t		<i class=\"glyphicon glyphicon-remove\" title=\"Файл удален\"></i>	\n\t	{{/file_deleted}}\n\t	<a id=\"{{id}}_href\" href=\"#\" title=\"Скачать файл\">\n\t		{{#file_not_deleted}}\n\t		{{file_name}}({{file_size_formatted}})\n\t		{{/file_not_deleted}}\n\t		\n\t		{{#file_deleted}}\n\t		<span class=\"text-thin\" title=\"Удален {{file_deleted_dt}}\">{{file_name}}({{file_size_formatted}})</span>\n\t		{{/file_deleted}}		\n\t	</a>\n\t	{{#file_not_deleted}}\n\t	{{#isClient}}<div id=\"{{id}}_del\" class=\"btn btn-sm fileDeleteBtn\" title=\"Удалить файл\"></div>{{/isClient}}\n\t	{{/file_not_deleted}}\n\t</li>\n\t\n\t","MailAttachment":"<li id=\"{{id}}\" {{#file_uploaded}}uploaded=\"true\"{{/file_uploaded}} file_id=\"{{file_id}}\" file_name=\"{{file_name}}\">\n\t	{{#file_uploaded}}\n\t	<i class=\"glyphicon glyphicon-ok\" title=\"Файл загружен на сервер\"></i>	\n\t	{{/file_uploaded}}\n\t	{{#file_not_uploaded}}\n\t	<i class=\"file-pic glyphicon glyphicon-cloud-upload\" title=\"Необходимо загрузить файл!\"></i>\n\t	{{/file_not_uploaded}}\n\t	<a id=\"{{id}}_href\" href=\"#\" title=\"Скачать файл\">\n\t		{{file_name}}({{file_size_formatted}})\n\t	</a>\n\t	{{#isNotSent}}<div id=\"{{id}}_del\" class=\"btn btn-sm fileDeleteBtn\" title=\"Удалить файл\"></div>{{/isNotSent}}\n\t</li>\n\t\n\t","ApplicationClientContainer":"<div id=\"{{id}}\">\n\t	<div id=\"{{id}}:container\">\n\t	</div>\n\t	{{#isClient}}\n\t	<div id=\"{{id}}:cmdAdd\">\n\t	</div>	\n\t	{{/isClient}}\n\t</div>\n\t"};