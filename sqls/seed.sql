DROP TABLE IF EXISTS public.dummy CASCADE;
CREATE TABLE public.dummy (
    id                     SERIAL PRIMARY KEY,
    text                   VARCHAR NULL
);

DROP FUNCTION IF EXISTS public.insert_dummy_records;
CREATE FUNCTION public.insert_dummy_records(
    number_rows INTEGER DEFAULT 1 -- number row to generate
) RETURNS VOID
LANGUAGE 'plpgsql'
AS $$
BEGIN
    INSERT INTO public.dummy (text)
    SELECT NOW() FROM GENERATE_SERIES(0, number_rows);
END;
$$;
