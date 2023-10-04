\echo "Loading fixtures..."

SET client_min_messages TO WARNING;

TRUNCATE public.users;

INSERT INTO public.users
    (
        username
    )
    VALUES
    (
        'user1'
    ),
    (
        'user2'
    ),
    (
        'user3'
    );

\echo "Fixtures loaded"
