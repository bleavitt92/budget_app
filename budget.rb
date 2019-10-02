require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:budget] ||= []
  session[:months] ||= {}
end

helpers do
  def update_total
    total = 0
    @budget.each do |indiv_budgets|
      total += indiv_budgets[:amount].to_i
    end
    total
  end

  def todate_spending_total
    todate_spending = 0
    @budget.each do |indiv_budgets|
      todate_spending += indiv_budgets[:todate]
    end
    todate_spending
  end

  def amount_left_total
    amount_left = 0
    @budget.each do |indiv_budgets|
      amount_left += (indiv_budgets[:amount].to_i - indiv_budgets[:todate].to_i)
    end
    amount_left
  end

  def new_month
    session[:months][""] = []
  end

  def reset_budget
    session[:budget] = []
    @budget = session[:budget]
  end

  def find_months
    # code to get an array on months included so far in the data
  end
end

get "/" do
  redirect "/budget"
end

get "/budget" do
  @budget = session[:budget]
  @month = session[:months].keys[-1] # returns the most recently entered month 
  @months = session[:months]
  erb :budget
end

get "/new_category" do
  erb :new_category
end

# go to overall month budget
get "/budget/months" do
  @budget = session[:budget]
  erb :months
end

# go to specific month's budget
get "/budget/:month" do
  redirect "/"
end

# add a new category
post "/new_category" do
  category_name = params[:category_name]
  category_amount = params[:category_amount]
  @todate_amount = 0
  session[:budget] << {category: category_name, amount: category_amount, todate: @todate_amount}
  session[:success] = "The budget has been created."
  redirect "/budget"
end

# add to current spending
post "/new_spending/:id" do
  id = params[:id].to_i
  amount = params[:new_spending].to_i
  session[:budget][id][:todate] += amount

  redirect "/budget"
end

# Add a new month
post "/budget/new_month" do
  month = params[:current_month]
  session[:months][month] = session[:budget]

  redirect "/budget"
end

# finalize this month's budget. Need to save the old month, and clear out @month instance variable
post "/finalize_month" do
  new_month

  redirect "/budget"
end
