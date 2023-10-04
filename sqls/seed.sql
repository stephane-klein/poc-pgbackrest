DROP TABLE IF EXISTS public.users CASCADE;
CREATE TABLE public.users (
    id                     SERIAL PRIMARY KEY,
    username               VARCHAR NULL UNIQUE
);
