-- Test to ensure all customers have non-negative total revenue
select 
    customer_id,
    total_revenue
from {{ ref('dim_customers') }}
where total_revenue < 0