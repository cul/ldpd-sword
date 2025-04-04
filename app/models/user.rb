# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable,
  # and :registerable.
  devise :database_authenticatable, :validatable,
         :omniauthable, omniauth_providers: [:cas]
end
