require 'rails_helper'

RSpec.describe 'PasswordResetsController', type: :routing do
  describe 'routing' do
    it 'routes to #new' do
      expect(get: '/password_resets/new').to route_to('password_resets#new')
    end

    it 'routes to #create' do
      expect(get: '/password_resets/create').to route_to('password_resets#create')
    end

    it 'routes to #edit' do
      expect(get: '/password_resets/edit').to route_to('password_resets#edit')
    end

    it 'routes to #update' do
      expect(get: '/password_resets/update').to route_to('password_resets#update')
    end
  end
end
