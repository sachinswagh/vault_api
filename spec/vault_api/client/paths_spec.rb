# frozen_string_literal: true

require 'spec_helper'
require 'vault_api/client/paths'

describe 'VaultApi::Client::Paths' do
  let (:address)  { 'https://vault-server.test.com' }
  let (:user)     { 'swagh' }
  let (:password) { 'test-password' }
  let (:env)      { 'development' }

  let (:secrets)  { ['awstest'] }
  let (:secret_base_path) { VaultApi.secret_base_path(user) }

  before do
    VaultApi.configure do |config|
      config.address = address
      config.user = user
      config.password = password
      config.env = env
    end
  end

  it 'delete_path' do
    expect(VaultApi).to receive(:list).with(secret_base_path).and_return(secrets)
    expect(VaultApi).to receive(:delete).with("#{secret_base_path}/#{secrets[0]}").and_return(true)
    expect(VaultApi).to receive(:delete).with(secret_base_path).and_return(true)
    response = VaultApi.delete_path(secret_base_path)
    expect(response).to eq(true)
  end
end
