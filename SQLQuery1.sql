select 
	ord.order_id,
	Concat(cus.first_name, ' ', cus.last_name) "Customers",
	cus.city,
	cus.state,
	ord.order_date,
	sum(ite.quantity) as 'Total_Units',
	sum(ite.quantity * ite.list_price) as 'revenue',
	pro.product_name,
	cat.category_name,
	brand.brand_name,
	store.store_name,
	CONCAT(staff.first_name, ' ', staff.last_name) as 'sales_rep'
from sales.orders ord
join sales.customers cus
on ord.customer_id = cus.customer_id
join sales.order_items ite
on ord.order_id = ite.order_id
join production.products pro
on pro.product_id = ite.product_id
join production.categories cat
on cat.category_id = pro.category_id
join sales.stores store
on store.store_id = ord.store_id
join sales.staffs staff
on staff.store_id = ord.store_id
join production.brands brand
on brand.brand_id = pro.brand_id
group by 
	ord.order_id,
	Concat(cus.first_name, ' ', cus.last_name),
	cus.city,
	cus.state,
	ord.order_date,
	pro.product_name,
	cat.category_name,
	brand.brand_name,
	store.store_name,
	CONCAT(staff.first_name, ' ', staff.last_name)
