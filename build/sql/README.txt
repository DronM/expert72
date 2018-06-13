Порядок работы триггеров:

	applications Вставка ТОЛЬКо на клиенте
	applications_process.sql BEFORE DELETE очистка писем
	На клиенте doc_flow_out_client,application_document_files
	На главном doc_flow_in_client,doc_flow_in,doc_flow_out,application_processes,contacts
	
	
	Вставка состояния в applications_processes ТОЛЬКО НА главном!
	application_processes_process() AFTER INSERT
	При отсылке нового заявления:
		На главном сервере - добавление контактов
		На клиентском сервере (репликационная вставка)- исх. письмо клиента (doc_flow_out_client)
	При статусах waiting_for_pay и expertise На главном сервере - письмо об изменении состояния клиенту
	
	
	Функция applications_split
	Отщипляет услугу от заявления, создает новое завление, как копию, оставляю новую услугу, новая услуга выбирается из старого заявления
 	Все файлы также переносятся
 	ЗАПУСКАЕТСЯ ИЗ Контроллера Application_Controller->set_state при sent=true при интерактивной подаче!
	
	
	doc_flow_out_client создается на клиенте
	doc_flow_out_client_process AFTER INSERT UPDATE
	на главном (репликационная вставка):
		Создать входящее письмо (doc_flow_in)на отдел приема/главный отдел контракта
		Напоминание&&email боссу о новом заявлении
		Напоминание&&email admin
		email на главный отдел если ответ на замечания
		
	
	doc_flow_in на клиент не уходит?	
	doc_flow_in_process
		на главном BEFORE INSERT
		Назначение reg_number автоматом на вход, при поступл.нового заявления и при ответе на замечания
		
	
	doc_flow_out на клиент не уходит?
	
	Рассмотрение
	doc_flow_examinations Вставка ТОЛЬКО на главном
	doc_flow_examinations_process
	AFTER INSERT
		Вставка статуса doc_flow_in_processes
		если тип основания - письмо, чье основание - заявление - сменим его статус application_processes на новый статус из Рассмотрения
		Новая задача вставка doc_flow_tasks
	AFTER UPDATE
		Изменение статуса doc_flow_in_processes
		если тип основания - письмо, чье основание - заявление - и статус waiting_for_contract
			НОВЫЙ КОНТРАКТ
			Новый/обновление клиент-заявитель(applicant)
	BEFORE DELETE
		doc_flow_in_processes
		doc_flow_tasks
		
	DoFlowExamination_Controller
	Проведение: разрыв свзяи cost_eval_validity_simult=FALSE
	
		
	Регистрация наших исходящих писем, на клиента не уходит
	doc_flow_registrations	
	doc_flow_registrations_process
		Вставка статуса doc_flow_out_processes
		если основание - заявление/контракт = ответное письмо клиенту
		Установка подписанта исходящего документа
		Вставка doc_flow_in_client
		Если нужно - письмо клиенту со ссылкой на вход.документ

		
	Согласование
	doc_flow_approvements создается на клиенте
	doc_flow_approvements_process
		Новый статус письма doc_flow_out_processes
		Новая задача по шагу
		При закоытии - задачу ответственному
		
		
	Контракты
	contracts Только на основном сервере, репликация
	contracts_process
		Установка скрытого поля прав
		
		
	client_payments Оплаты клиентов, только на основном, без реплицации
	client_payments_process
		Установка даты начала работ при первой оплате, даты окончания
		Установка тогоже в свзяном контракте (Дост вместе с ПД)
		
		
	doc_flow_tasks Любые задачи, ТОЛЬКо главный, без репликации
	doc_flow_tasks_process
		Вставка напоминаний reminders

		
	reminders Напоминания, только на главном без репликации
	reminders_process
		Новое письмо на емайл получателя напоминания ВСЕГДА!		
