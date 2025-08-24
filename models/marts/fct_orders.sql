{{ config(materialized='table') }}

select
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount,
    is_completed,
    case 
        when order_status = 'completed' then 'success'
        when order_status = 'pending' then 'in_progress'
        when order_status = 'cancelled' then 'failed'
        else 'unknown'
    end as order_category,
    extract(year from order_date) as order_year,
    extract(quarter from order_date) as order_quarter,
    extract(month from order_date) as order_month,
    current_timestamp as updated_at
from {{ ref('int_customer_orders') }}
where order_id is not null