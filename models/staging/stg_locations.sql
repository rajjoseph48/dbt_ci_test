{{ config(materialized='view') }}

select
    location_id,
    location_name,
    city,
    state,
    country,
    postal_code,
    warehouse_type,
    case 
        when is_active = 'true' then 1 
        else 0 
    end as is_active,
    cast(created_date as date) as created_date,
    current_timestamp as created_at
from {{ ref('raw_locations') }}