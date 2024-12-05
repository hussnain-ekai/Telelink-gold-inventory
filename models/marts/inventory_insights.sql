{{
  config(
    materialized='table',
    schema='inventory_mart',
    enabled=true,
    description='This model consolidates product and inventory data to provide detailed insights into stock availability and utilization across locations.'
  )
}}

with link_inventory as (
    select * from {{ ref('link_inventory') }}
),
hub_products as (
    select * from {{ ref('hub_products') }}
),
hub_stock_locations as (
    select * from {{ ref('hub_stock_locations') }}
),
sat_inventory as (
    select * from {{ ref('sat_inventory') }}
)

select
    link_inventory.link_inventory_key,
    hub_products.productname,
    hub_stock_locations.locationname,
    sum(sat_inventory.quantity_on_hand) as total_quantity_on_hand,
    sum(sat_inventory.quantity_reserved) as total_quantity_reserved,
    sum(sat_inventory.quantity_on_hand) + sum(sat_inventory.quantity_reserved) as total_inventory,
    sum(sat_inventory.quantity_reserved) / nullif(sum(sat_inventory.quantity_on_hand) + sum(sat_inventory.quantity_reserved), 0) as utilization_ratio
from link_inventory
join hub_products
    on link_inventory.hub_product_key = hub_products.hub_product_key
join hub_stock_locations
    on link_inventory.hub_location_key = hub_stock_locations.hub_location_key
join sat_inventory
    on link_inventory.link_inventory_key = sat_inventory.hub_inventory_key
group by
    link_inventory.link_inventory_key,
    hub_products.productname,
    hub_stock_locations.locationname