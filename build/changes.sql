изменить структуру file_verification,add user_certificates,
application_document_files_process,file_verifications_trigger,file_verifications_processes

doc_flow_out_dialog
doc_flow_attachments_process()
doc_flow_attachments_after_trigger
contracts_list
doc_flow_in_dialog
contracts_process()
contracts_dialog
doc_flow_out_client_process
INSERT INTO views (id,c,f,t,section,descr,limited)
VALUES ('30002','Contract_Controller',NULL,'RepReestrPay','Отчеты','Реестр оплат',FALSE);
applications_customer_list
INSERT INTO views
(id,c,f,t,section,descr,limited)
VALUES ('30003','Contract_Controller',NULL,'RepReestrContract','Отчеты','Реестр контрактов (выборка)',FALSE);
applications_contractors_list

UPDATE public.application_doc_folders SET name='Договорные документы/Контракт',require_client_sig=TRUE WHERE id='1';

INSERT INTO public.application_doc_folders(id, name,require_client_sig) VALUES (100, 'Договорные документы/Акт выполненных работ',TRUE);
INSERT INTO public.application_doc_folders(id, name,require_client_sig) VALUES (101, 'Договорные документы/Счет',FALSE);


  

applications_dialog
contracts_dialog
doc_flow_out_dialog
application_folders перенумеровать 1,2,3 100 - акт



doc_flow_contract_ret_date(in_doc_flow_out_client_id int)


--*******************************************


--*******************************************

DROP INDEX user_certificates_fingerprint_user_idx;
CREATE UNIQUE INDEX user_certificates_fingerprint_user_idx
  ON public.user_certificates
  USING btree
  (fingerprint,date_time_from);
  
  
  


select file_name,substring(file_name from 1 for position('.sig' in file_name)-1) from application_document_files where position('.sig' in file_name)>0 AND date_time::date=now()::date
/*
update application_document_files
set file_name=substring(file_name from 1 for position('.sig' in file_name)-1)
where position('.sig' in file_name)>0 AND date_time::date=now()::date
*/
