class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable, :omniauthable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable, omniauth_providers: %i[facebook],
                                                                             timeoutable: false
end
