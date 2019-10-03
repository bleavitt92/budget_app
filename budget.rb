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
      total += indiv_budgets[:todate].to_i
    end
    total
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

# add a new category
post "/budget/:month/new_category" do
  category_name = params[:category_name]
  category_amount = params[:category_amount]
  current_month = params[:month]
  todate_amount = 0
  session[:budget][current_month] << {category: category_name, amount: category_amount, todate: todate_amount}
  session[:success] = "The budget has been created."
  redirect "/budget/#{current_month}"
end

# add to current spending
post "/budget/:month/new_spending/:id" do
  id = params[:id].to_i
  amount = params[:new_spending].to_i
  current_month = params[:month]
  session[:budget][current_month][id][:todate] += amount

  redirect "/budget/#{current_month}"
end

# delete budget item
post "/budget/:month/:id/delete" do
  current_month = params[:month]
  id = params[:id].to_i
  months_budget = session[:budget][current_month]
  months_budget.delete_at(id)

  redirect "/budget/#{current_month}"
end

post "/budget/:month/:id/edit" do
  category_name = params[:category_name]
  category_amount = params[:category_amount]
  current_month = params[:month]
  todate = params[:todate]
  id = params[:id].to_i
  todate_amount = 0
  session[:budget][current_month][id][:category] = category_name
  session[:budget][current_month][id][:amount] = category_amount
  session[:budget][current_month][id][:todate] = todate
  session[:success] = "Budget updated!"
  redirect "/budget/#{current_month}"
end


