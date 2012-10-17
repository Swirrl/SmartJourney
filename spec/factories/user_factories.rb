FactoryGirl.define do
  factory :user do
    email 'ric@swirrl.com'
    password 'password'
    screen_name 'ricroberts'
  end

  factory :admin_user, class: User do
    email 'super@swirrl.com'
    password 'password'
    screen_name 'super'
    roles User::ROLES
  end
end
