{{ config(materialized='table') }}

select
    customer_id,
    full_name,
    email_lower as email,
    registration_date,
    count(case when is_completed = 1 then 1 end) as completed_orders,
    count(order_id) as total_orders,
    coalesce(sum(case when is_completed = 1 then total_amount end), 0) as total_revenue,
    coalesce(avg(case when is_completed = 1 then total_amount end), 0) as avg_order_value,
    min(order_date) as first_order_date,
    max(order_date) as last_order_date,
    current_timestamp as updated_at
from {{ ref('int_customer_orders') }}
group by 
    customer_id,
    full_name,
    email_lower,
    registration_date