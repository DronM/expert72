-- Trigger: doc_flow_tasks_processes_after_trigger on doc_flow_tasks_processes

-- DROP TRIGGER doc_flow_tasks_after_trigger ON doc_flow_tasks_processes;

 CREATE TRIGGER doc_flow_tasks_after_trigger
  AFTER INSERT OR UPDATE
  ON doc_flow_tasks
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_tasks_process();
  
-- DROP TRIGGER doc_flow_tasks_before_trigger ON doc_flow_tasks_processes;

 CREATE TRIGGER doc_flow_tasks_before_trigger
  BEFORE DELETE OR UPDATE
  ON doc_flow_tasks
  FOR EACH ROW
  EXECUTE PROCEDURE doc_flow_tasks_process();
    
