-- ==========================================================
-- LEQVOR SUBSCRIPTION ACCESS TRIGGERS
-- This enforces read-only mode at the database level for 
-- expired accounts, without editing 24 individual functions.
-- ==========================================================

-- 1. Create the security guard function
CREATE OR REPLACE FUNCTION public.enforce_subscription_access()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid;
BEGIN
  -- Extract user ID directly from JWT claims (100% reliable in triggers)
  v_user_id := (current_setting('request.jwt.claims', true)::jsonb)->>'sub';

  -- Allow service role (background jobs, webhooks, Edge Functions)
  IF v_user_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Check if the user has an active, valid subscription
  IF EXISTS (
    SELECT 1 FROM public.subscriptions s
    WHERE s.user_id = v_user_id
    AND (
      (s.status = 'trial' AND s.trial_ends_at > now())
      OR (s.status = 'active' AND s.current_period_end > now())
      OR (s.status = 'pilot' AND s.pilot_ends_at > now())
    )
  ) THEN
    RETURN NEW; -- User is active, allow the write operation
  END IF;

  -- Block the operation and throw a clear error.
  RAISE EXCEPTION 'LEQVOR_ACCESS_DENIED: Your subscription is expired or inactive. Your account is currently in read-only mode. Please renew to make changes.';
END;
$$;

-- 2. Install the security guard on your core tables
-- Records Table
DROP TRIGGER IF EXISTS trg_enforce_access_records ON public.records;
CREATE TRIGGER trg_enforce_access_records
  BEFORE INSERT OR UPDATE OR DELETE ON public.records
  FOR EACH ROW EXECUTE FUNCTION public.enforce_subscription_access();

-- Record Files Table
DROP TRIGGER IF EXISTS trg_enforce_access_record_files ON public.record_files;
CREATE TRIGGER trg_enforce_access_record_files
  BEFORE INSERT OR UPDATE OR DELETE ON public.record_files
  FOR EACH ROW EXECUTE FUNCTION public.enforce_subscription_access();

-- Record Versions Table
DROP TRIGGER IF EXISTS trg_enforce_access_record_versions ON public.record_versions;
CREATE TRIGGER trg_enforce_access_record_versions
  BEFORE INSERT OR UPDATE OR DELETE ON public.record_versions
  FOR EACH ROW EXECUTE FUNCTION public.enforce_subscription_access();

-- Family Members Table
DROP TRIGGER IF EXISTS trg_enforce_access_family_members ON public.family_members;
CREATE TRIGGER trg_enforce_access_family_members
  BEFORE INSERT OR UPDATE OR DELETE ON public.family_members
  FOR EACH ROW EXECUTE FUNCTION public.enforce_subscription_access();

-- Trusted People Table
DROP TRIGGER IF EXISTS trg_enforce_access_trusted_people ON public.trusted_people;
CREATE TRIGGER trg_enforce_access_trusted_people
  BEFORE INSERT OR UPDATE OR DELETE ON public.trusted_people
  FOR EACH ROW EXECUTE FUNCTION public.enforce_subscription_access();

-- Legacy Statements Table
DROP TRIGGER IF EXISTS trg_enforce_access_legacy_statements ON public.legacy_statements;
CREATE TRIGGER trg_enforce_access_legacy_statements
  BEFORE INSERT OR UPDATE OR DELETE ON public.legacy_statements
  FOR EACH ROW EXECUTE FUNCTION public.enforce_subscription_access();