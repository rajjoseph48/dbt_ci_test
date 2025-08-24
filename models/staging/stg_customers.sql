{{ config(materialized='view') }}

select
    customer_id,
    first_name,
    last_name,
    email,
    registration_date::date as registration_date,
    concat(first_name, ' ', last_name) as full_name,
    lower(email) as email_lower
from {{ ref('raw_customers') }}
where email is not null