# frozen_string_literal: true

require 'spec_helper'
require 'vault_api/client/secrets'

describe 'VaultApi::Client::Secrets' do
  let (:address)  { 'https://vault-server.test.com' }
  let (:user)     { 'swagh' }
  let (:password) { 'test-password' }
  let (:env)      { 'development' }

  let (:secrets)  { ['awstest'] }
  let (:secret_base_path)  { VaultApi.secret_base_path(user) }
  let (:secret_name)  { 'awstest' }
  let (:secret_path)  { "#{secret_base_path}/#{secret_name}" }
  let (:secrets_folder_path)  { '../../../fixtures/secrets' }

  before do
    VaultApi.configure do |config|
      config.address = address
      config.user = user
      config.password = password
      config.env = env
    end
  end

  it 'list_secrets' do
    expect(VaultApi).to receive(:list).with(secret_base_path).and_return(secrets)
    response = VaultApi.secrets
    expect(response).to eq(secrets)
  end

  it 'add_secret' do
    secrets_hash = load_secret_hash
    expect(VaultApi).to receive(:write).with(secret_path, secrets_hash).and_return(true)
    secret_file_path = File.expand_path(secrets_folder_path, __FILE__)
    response = VaultApi.add_secret("#{secret_file_path}/#{secret_name}.yml")
    expect(response).to eq(true)
  end

  it 'read_secret' do
    secret_object = load_secret_object
    expect(VaultApi).to receive(:read).with(secret_path).and_return(secret_object)
    response = VaultApi.read_secret(secret_name)
    expect(response).to eq(secret_object.data)
  end

  it 'update_secret' do
    secrets_hash = load_secret_hash
    expect(VaultApi).to receive(:write).with(secret_path, secrets_hash).and_return(true)
    secret_file_path = File.expand_path(secrets_folder_path, __FILE__)
    response = VaultApi.update_secret("#{secret_file_path}/#{secret_name}.yml")
    expect(response).to eq(true)
  end

  it 'upload_secrets' do
    secrets_hash = load_secret_hash
    expect(VaultApi).to receive(:write).with(secret_path, secrets_hash).and_return(true)
    secret_file_path = File.expand_path(secrets_folder_path, __FILE__)
    response = VaultApi.upload_secrets(secret_file_path)
    expect(response).to eq(['awstest.yml'])
  end

  it 'delete_secret' do
    secrets_hash = load_secret_hash
    expect(VaultApi).to receive(:delete).with("#{secret_base_path}/#{secret_name}").and_return(true)
    response = VaultApi.delete_secret(secret_name)
    expect(response).to eq(true)
  end

  def load_secret_hash
    config_file_path = File.expand_path(secrets_folder_path, __FILE__)
    config_file_path = "#{config_file_path}/#{secret_name}.yml"
    output_json = JSON.dump(YAML::load_file(config_file_path))
    JSON.parse(output_json)[VaultApi.env]#.symbolize_keys
  end

  def load_secret_object
    OpenStruct.new(data: load_secret_hash.symbolize_keys)
  end
end
