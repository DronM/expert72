-- Trigger: contracts_before_trigger on contracts

 DROP TRIGGER contracts_before_trigger ON contracts;

 CREATE TRIGGER contracts_before_trigger
  BEFORE INSERT OR UPDATE OR DELETE
  ON contracts
  FOR EACH ROW
  EXECUTE PROCEDURE contracts_process();
