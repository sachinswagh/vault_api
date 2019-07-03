# frozen_string_literal: true

require 'spec_helper'
require 'vault_api/client/users'

describe 'VaultApi::Client::users' do
  let (:address)  { 'https://vault-server.test.com' }
  let (:user)     { 'swagh' }
  let (:password) { 'test-password' }
  let (:env)      { 'development' }

  let (:secrets)  { ['awstest'] }
  let (:secret_name) { 'awstest' }
  let (:secret_base_path) { VaultApi.secret_base_path(user) }
  let (:secret_path) { "#{secret_base_path}/#{secret_name}" }

  let (:user_base_path) { "/#{VaultApi.auth_users_path}/#{user}" }
  let (:global_path) { VaultApi.secret_global_base_path }
  let (:secrets_folder_path) { '../../../fixtures/secrets' }

  before do
    VaultApi.configure do |config|
      config.address = address
      config.user = user
      config.password = password
      config.env = env
    end
  end

  it 'delete_user' do
    expect(VaultApi).to receive(:delete).with(user_base_path).and_return(true)
    expect(VaultApi).to receive(:delete_policy).with("#{user}_policy").and_return(true)

    expect(VaultApi).to receive(:list).with(secret_base_path).and_return(secrets)
    expect(VaultApi).to receive(:delete).with("#{secret_base_path}/#{secrets[0]}").and_return(true)
    expect(VaultApi).to receive(:delete).with(secret_base_path).and_return(true)

    response = VaultApi.delete_user(user)
    expect(response).to eq(true)
  end

  it 'add_secrets_to_user_from_global' do
    expect(VaultApi).to receive(:list).with(global_path).and_return(secrets)
    filename = secrets[0]

    secret_object = load_secret_object
    expect(VaultApi).to receive(:read).with("#{global_path}/#{filename}").and_return(secret_object)
    expect(VaultApi).to receive(:write).with(secret_path.to_s, secret_object.data).and_return(true)

    response = VaultApi.add_secrets_to_user_from_global(user)
    expect(response).to eq(['awstest'])
  end

  def load_secret_hash
    config_file_path = File.expand_path(secrets_folder_path, __FILE__)
    config_file_path = "#{config_file_path}/#{secret_name}.yml"
    output_json = JSON.dump(YAML.load_file(config_file_path))
    JSON.parse(output_json)[VaultApi.env] # .symbolize_keys
  end

  def load_secret_object
    OpenStruct.new(data: load_secret_hash.symbolize_keys)
  end
end
