{{ config(materialized='view') }}

select
    c.customer_id,
    c.full_name,
    c.email_lower,
    c.registration_date,
    o.order_id,
    o.order_date,
    o.status as order_status,
    o.total_amount,
    o.is_completed
from {{ ref('stg_customers') }} c
left join {{ ref('stg_orders') }} o 
    on c.customer_id = o.customer_id