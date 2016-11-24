require "sequel"

DB = Sequel.connect("postgres:/sequel-single-table")

def format_money(num)
  format("%0.2f", num)
end

menu_items = DB[:menu_items]

items = menu_items.select do
  labor_cost = prep_time / 60.0 * 12
  profit_calc = menu_price - (ingred_cost + prep_time / 60.0 * 12)
  [ item, 
    menu_price,
    ingred_cost,
    labor_cost.as(labor),
    profit_calc.as(profit) ]
end

items = items.order(Sequel.desc(:profit))

items.each do |item|
  puts item[:item]
  puts "menu price: $#{format_money(item[:menu_price])}"
  puts "ingredient cost: $#{format_money(item[:ingred_cost])}"
  puts "labor: $#{format_money(item[:labor])}"
  puts "profit: $#{format_money(item[:profit])}"
  puts "\n"
end


DB.create_table(:birds) do
  primary_key :id
  String :name, {null: false}
  Float :length, {null: false, default: 0}
  Float :wingspan, {null: false, default: 0}
  String :family, {null: false}
  TrueClass :extinct, {null: false, default: false}
end

DB.create_table(:menu_items) do
  primary_key :id
  String :item, {null: false, unique: true}
  Integer :prep_time, {null: false, default: 0}
  Float :ingred_cost, {null: false, default: 0.00}
  Integer :sales, {null: false, default: 0}
  Float :menu_price, {null: false, deafult: 0.00}
end

DB.alter_table(:menu_items) do
  set_column_type :ingred_cost, :Numeric, size: [4, 2]
  set_column_type :prep_time, :Integer
end

menu_items = DB[:menu_items]

menu_items.insert([:item, :prep_time, :ingred_cost, :sales, :menu_price],
                  ["omelette", 10, 1.50, 182, 7.99])


item = menu_items.select { [item, (menu_price - ingred_cost).as(profit)] }.order(Sequel.desc(:profit)).first

# Above in SQL string equivalent =>
"SELECT item, (menu_price - ingred_cost) AS profit FROM menu_items
ORDER BY profit DESC LIMIT 1;"

# To return the actual SQL query being used, you could: 
menu_items.select { [item, (menu_price - ingred_cost).as(profit)] }.order(Sequel.desc(:profit)).limit(1).sql

item[:profit].to_f

# ======================
tickets.distinct(:customer_id)

uniq_sales = tickets.select { count(customer_id).distinct.cast(Float) }.first[:count]

total_customers = customers.select { count(id).cast(Float) }.first[:count]

# OR ====

customers.select {
  (count(tickets__customer_id).distinct / count(customers__id).distinct.cast(Float) * 100).as(:percent)
}.left_outer_join(:tickets, customer_id: :id).first

# ========

events = DB[:events]

ticket_count = events.select {
  [events__name, count(tickets__event_id).as(:tickets_sold)]
}.left_outer_join(:tickets, event_id: :id).group_by(:name).order(Sequel.desc(:tickets_sold))

ticket_count.each do |event|
  puts "#{event[:name]}: #{event[:tickets_sold]}"
end

"SELECT customers.id, customers.email, COUNT(DISTINCT tickets.event_id) AS events
FROM customers
INNER JOIN tickets ON customers.id = tickets.customer_id
GROUP BY customers.id
HAVING COUNT(DISTINCT tickets.event_id) >= 3
ORDER BY events DESC
LIMIT 20;"

customers = DB[:customers]

# SOLUTION:
customers.select do
  [customers__id,
   customers__email,
   count(tickets__event_id).distinct.as(:events)]
end.
left_outer_join(:tickets, customer_id: :id).group(:customers__id).
having { count(tickets__event_id).distinct >= 3 }.all

"SELECT events.name, events.starts_at, sections.name, seats.row, seats.number
FROM customers
INNER JOIN tickets ON customers.id = tickets.customer_id
INNER JOIN events ON tickets.event_id = events.id
INNER JOIN seats ON tickets.seat_id = seats.id
INNER JOIN sections ON seats.section_id = sections.id
WHERE customers.email = 'gennaro.rath@mcdermott.co';"

customers.select {
  [events__name,
   events__starts_at,
   sections__name.as(:section_name),
   seats__row,
   seats__number]
}.inner_join(:tickets, customer_id: :id).
inner_join(:events, id: :tickets__event_id).
inner_join(:seats, id: :tickets__seat_id).
inner_join(:sections, id: :seats__section_id).
where { customers__email =~ 'gennaro.rath@mcdermott.co' }
