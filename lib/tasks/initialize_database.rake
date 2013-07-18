namespace :db do

  task initialize_user_plans: :environment do
    create_plan(FREE,    10,    2,   0.0,  7)
    create_plan(ADMIN,   100, 100,   0.0, 370)
    create_plan(PREMIUM, 10,    2, 100.0,  90)    
  end


  def create_plan(plan_type, nc, nl, p, r)
    plan = Plan.find_by_name(plan)
    if plan.nil?
      plan = Plan.new
      plan.name = plan_type
      plan.num_competitors = nc
      plan.num_lists = nl
      plan.price = p
      plan.max_date_range = r
      plan.save
    end 
    puts "Created plan #{plan_type}"   
  end

end