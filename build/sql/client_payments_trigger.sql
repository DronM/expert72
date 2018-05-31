-- Trigger: client_payments_trigger on client_payments

-- DROP TRIGGER client_payments_after_trigger ON client_payments;

CREATE TRIGGER client_payments_after_trigger
  AFTER INSERT
  ON client_payments
  FOR EACH ROW
  EXECUTE PROCEDURE client_payments_process();

