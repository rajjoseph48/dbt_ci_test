{{ config(materialized='view') }}

select
    order_id,
    customer_id,
    order_date::date as order_date,
    status,
    total_amount::decimal(10,2) as total_amount,
    case 
        when status = 'completed' then 1
        else 0
    end as is_completed
from {{ ref('raw_orders') }}
where order_date is not null