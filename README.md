Аутентификация для спецпроектов [Lookatme](http://www.lookatme.ru) и [The Village](http://www.the-village.ru)

## Установка

    gem install lam_auth

После установки/добавления в Gemfile:

    rails generate lam_auth

после этого нужно добавить настройки приложения в `config/lam_auth.yml`. 

Для спецпроектов The Village необходимо в `config/lam_auth.yml` добавить:

    site: village

## Подключение панели

Подключить js-код в head:
  
    <%= lam_auth_include_tag %>
  
Затем:

    <div id="lam-root"></div>
    <%= lam_auth_init_tag %>

В случае с The Village дефолтный `id` панели `village-root`.

## Модель

При аутентификации Lookatme/The Village возвращают данные пользователя в следующем виде:

```ruby
{
  "gender"     => "male",
  "last_name"  => "Маковский",
  "city"       => "Москва",
  "email"      => "robotector@gmail.com",
  "userpic"    => {
    "medium"   => "http://assets3.lookatme.ru/assets/user-userpic/20/38/3/user-userpic-medium.jpg",
    "big"      => "http://assets0.lookatme.ru/assets/user-userpic/20/38/3/user-userpic-big.jpg",
    "icon"     => "http://assets3.lookatme.ru/assets/user-userpic/20/38/3/user-userpic-icon.jpg",
    "thumb"    => "http://assets0.lookatme.ru/assets/user-userpic/20/38/3/user-userpic-thumb.jpg"
  },
  "first_name" => "Шляпа",
  "birthday"   => "13-12-1979",
  "login"      => "macovsky"}
```

В модели пользователя нужно подключить `LamAuth`:

```ruby
class User < ActiveRecord::Base
  include LamAuth::Model
end
```

Теперь класс `User` имеет метод `create_or_update_by_auth_data`, принимающий данные пользователя:

```ruby
def self.create_or_update_by_auth_data(data)
  user = find_or_initialize_by_login(data['login'])
  user.update_attributes! data.slice(*%w{email first_name last_name}).merge(
    'userpic' => data['userpic']['icon'], 
    'profile' => data.except(*%w{login email first_name last_name userpic})
  )
  user
end
```

Предполагает наличие соответствующих атрибутов и сериализацию атрибута `profile`: 

```ruby
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :login, :null => false
      t.string :email, :null => false
      t.string :first_name
      t.string :last_name
      t.string :userpic
      t.text :profile
      t.timestamps
    end
    
    add_index :users, :login
    add_index :users, :email
  end

  def self.down
    drop_table :users
  end
end
```

Метод переопределяется для конкретных случаев.

## Контроллер

Для подключения самого механизма аутентификации можно, например, использовать [RailsWarden](http://github.com/hassox/rails_warden):

```ruby
# config/initializers/warden.rb
Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :cookie_with_access_token
  manager.failure_app = SessionsController
end

Warden::Strategies.add(:cookie_with_access_token) do
  def authenticate!
    access_token = LamAuth.access_token_from_cookie(request.cookies[LamAuth.cookie_id])
    access_token ? success!(User.find_by_access_token(access_token)) : fail
  end
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate
  before_filter :logout_if_no_cookie_available, :if => :logged_in?

  private

  def logout_if_no_cookie_available
    logout if !LamAuth.access_token_from_cookie(cookies[LamAuth.cookie_id])
  end
end

# app/controllers/sessions_controller.rb 
# Контроллер, который в #unauthenticated рендерит сообщение о необходимости авторизоваться/зарегистрироваться.
class SessionsController < ApplicationController
  def unauthenticated
  end
end
```

На страницах, где аутентификация обязательна, можно использовать соответствующий хелпер `RailsWarden`:

```ruby
before_filter :authenticate!
```
