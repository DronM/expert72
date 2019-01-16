-- Trigger: expertise_prolongations_trigger on public.expertise_prolongations

-- DROP TRIGGER expertise_prolongations_trigger ON public.expertise_prolongations;

CREATE TRIGGER expertise_prolongations_trigger
  BEFORE UPDATE OR INSERT
  ON public.expertise_prolongations
  FOR EACH ROW
  EXECUTE PROCEDURE public.expertise_prolongations_process();

