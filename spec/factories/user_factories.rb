FactoryGirl.define do
  factory :user do
    email 'ric@swirrl.com'
    password 'password'
    screen_name 'ricroberts'
  end

  factory :user2, class: User do
    email 'bill@swirrl.com'
    password 'password'
    screen_name 'billroberts'
  end

  factory :user3, class: User do
    email 'sarah@swirrl.com'
    password 'password'
    screen_name 'sarahroberts'
  end

  factory :admin_user, class: User do
    email 'super@swirrl.com'
    password 'password'
    screen_name 'super'
    roles User::ROLES
  end
end
