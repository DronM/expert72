-- Trigger: users_before_trigger on public.users

-- DROP TRIGGER users_before_trigger ON public.users;

CREATE TRIGGER users_before_trigger
  BEFORE UPDATE
  ON public.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.users_process();

