require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "date"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:budget] ||= {
    'january' => [], 
    'february' => [],
    'march' => [],
    'april' => [],
    'may' => [],
    'june' => [],
    'july' => [],
    'august' => [],
    'september' => [],
    'october' => [],
    'november' => [],
    'december' => [],
  }
end

helpers do
  def total(current_month)
    total = 0
    @budget[current_month].each do |indiv_budgets|
      total += indiv_budgets[:amount].to_i
    end
    total
  end

  def spending_total(current_month)
    total = 0
    @budget[current_month].each do |indiv_budgets|
      indiv_budgets[:items].each do |item, cost|
        total += cost
      end
    end
    total
  end

  def category_spending_total(current_month, id)
    total = 0
    @budget[current_month][id][:items].each do |item, cost|
      total += cost
    end
    total
  end
end

# Return an error message if the name is invalid. Return nil if name is valid.
def error_for_name(name, current_month)
  if !(1..100).cover? name.size
    "Must be between 1 and 100 characters."
  elsif session[:budget][current_month].any? { |budget_item| budget_item[:category] == name }
    "Category name must be unique."
  end
end

# Return an error message if the item name is invalid. Return nil if name is valid.
def error_for_item_name(name, current_month)
  if !(1..100).cover? name.size
    "Must be between 1 and 100 characters."
  elsif session[:budget][current_month].any? { |budget_item| budget_item[:item] == name }
    "Item name must be unique."
  end
end

def error_for_amount(price)
  if price.to_i.to_s != price
    "Price must be expressed in terms of numbers only. No symbols ($ or ,)"  
  elsif price.to_i < 0
    "Price must be between $0 and $1,000,000,000,000"
  elsif price.to_i > 1000000000000
    "Price must be between $0 and $1,000,000,000,000"
  end
end

def todays_month # returns a string for what month it is
  months = ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 
            'september', 'october', 'november', 'december']
  months[Date.today.month-1]
end

get "/home" do
  current_month = todays_month
  redirect "/budget/#{current_month}"
end

get "/" do
  redirect "/home"
end

get "/budget/:month" do
  @budget = session[:budget]
  @current_month = params[:month]
  
  erb :month, layout: :layout
end

get "/budget/:month/new_category" do
  @current_month = params[:month]

  erb :new_category
end

# go to overall year budget
get "/budget" do
  @budget = session[:budget]

  erb :year
end

# edit budget item
get "/budget/:month/:id/edit" do
  @current_month = params[:month]
  @id = params[:id].to_i
  @months_budget = session[:budget][@current_month]

  erb :edit
end

# pull up page to add to current spending on certain category and month
get "/budget/:month/new_spending/:id" do
  @id = params[:id]
  @current_month = params[:month]

  erb :new_spending
end

# add a new category
post "/budget/:month/new_category" do
  category_name = params[:category_name]
  category_amount = params[:category_amount]
  current_month = params[:month]
  todate_amount = 0

  error = error_for_name(category_name, current_month) || error = error_for_amount(category_amount)
  if error
    session[:error] = error
    redirect "/budget/#{current_month}/new_category"
  else
    session[:budget][current_month] << {category: category_name, amount: category_amount, todate: todate_amount, items: {}}
    session[:success] = "The budget has been created."
    redirect "/budget/#{current_month}"
  end
end

# add to current spending
post "/budget/:month/new_spending/:id" do
  id = params[:id].to_i
  current_month = params[:month]
  item = params[:item]
  item_amount = params[:item_amount]

  error = error_for_amount(item_amount) || error = error_for_item_name(item, current_month)
  if 
    session[:error] = error
    redirect "/budget/#{current_month}/new_spending/#{id}"   
  else
    session[:budget][current_month][id][:items][item] = item_amount.to_i
    session[:budget][current_month][id][:todate] += item_amount.to_i
    redirect "/budget/#{current_month}"
  end
end

# delete budget category
post "/budget/:month/:id/delete" do
  current_month = params[:month]
  id = params[:id].to_i
  months_budget = session[:budget][current_month]
  months_budget.delete_at(id)

  redirect "/budget/#{current_month}"
end

# edit budget amount, name, or items bought
post "/budget/:month/:id/edit" do
  category_name = params[:category_name]
  category_amount = params[:category_amount]
  current_month = params[:month]
  todate = params[:todate]
  id = params[:id].to_i

  session[:budget][current_month][id][:category] = category_name
  session[:budget][current_month][id][:amount] = category_amount
  session[:budget][current_month][id][:todate] = todate.to_i
  session[:success] = "Budget updated!"
  
  redirect "/budget/#{current_month}"
end

# delete an item from category's expenses
post "/budget/:month/:id/:item/delete" do
  current_month = params[:month]
  id = params[:id].to_i
  item = params[:item]
  cost = session[:budget][current_month][id][:items][item]

  session[:budget][current_month][id][:items].delete(item)
  session[:budget][current_month][id][:todate] -= cost

  redirect "/budget/#{current_month}"
end







