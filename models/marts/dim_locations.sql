{{ config(materialized='table') }}

select
    location_id,
    location_name,
    city,
    state,
    country,
    postal_code,
    warehouse_type,
    is_active,
    created_date,
    case 
        when warehouse_type = 'distribution' then 'High Volume'
        when warehouse_type = 'fulfillment' then 'Customer Facing'
        when warehouse_type = 'storage' then 'Inventory Hold'
        else 'Unknown'
    end as location_category,
    case 
        when is_active = 1 then 'Operational'
        else 'Inactive'
    end as status_description,
    current_timestamp as updated_at
from {{ ref('stg_locations') }}