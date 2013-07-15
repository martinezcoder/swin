namespace :db do
  
  task delete_broken_data_days: :environment do
    delete_broken_data_days
  end

  task initialize_user_plans: :environment do
    create_plan(FREE,    10,    2,   0.0,  15)
    create_plan(ADMIN,   100, 100,   0.0, 370)
    create_plan(PREMIUM, 10,    2, 100.0,  90)    
    set_plan_to_all_users(FREE)
  end

  def delete_broken_data_days
    days = PageDataDay.where("day > ?", 29990101)
    days.each do |d|
      d.destroy
    end
    stream = PageStream.all
    stream.each do |s|
      s.destroy
    end
  end

  def set_plan_to_all_users(plan_type)
    plan =  Plan.find_by_name(plan_type)
    users = User.all
    users.each do |u|
      u.set_plan!(plan)
      u.save 
    end
    puts "done."
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