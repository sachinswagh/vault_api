# frozen_string_literal: true

require 'spec_helper'
require 'vault_api/client/policies'

describe 'VaultApi::Client::Policies' do
  let (:address)  { 'https://vault-server.test.com' }
  let (:user)     { 'swagh' }
  let (:password) { 'test-password' }
  let (:env)      { 'development' }

  let (:secret_base_path) { VaultApi.secret_base_path(user) }
  let (:user_name) { user }
  let (:secret_path) { secret_base_path }
  let (:policy) { OpenStruct.new(name: "#{user}_policy", rules: policy_json(user)) }

  before do
    VaultApi.configure do |config|
      config.address = address
      config.user = user
      config.password = password
      config.env = env
    end
  end

  it 'create_initial_user_policy' do
    expect(VaultApi).to receive(:put_policy).with("#{user_name}_policy", policy_json(user)).and_return(true)
    response = VaultApi.create_initial_user_policy(user)
    expect(response).to eq(true)
  end

  it 'create_policy' do
    expect(VaultApi).to receive(:put_policy).with("#{user_name}_policy", create_policy_rules.to_json).and_return(true)
    response = VaultApi.client.create_policy(user, secret_path, [:read])
    expect(response).to eq(true)
  end

  it 'read_policy' do
    expect(VaultApi).to receive(:policy).with("#{user_name}_policy").and_return(policy)
    response = VaultApi.read_policy(user_name)
    expect(response).to eq(policy)
  end

  it 'update_policy' do
    expect(VaultApi).to receive(:policy).with("#{user_name}_policy").and_return(policy)
    expect(VaultApi).to receive(:put_policy).with("#{user_name}_policy", update_policy_rules.to_json).and_return(true)
    response = VaultApi.client.update_policy(user, "#{secret_path}/*", [:read])
    expect(response).to eq(true)
  end

  it 'delete_policy' do
    expect(VaultApi).to receive(:delete_policy).with("#{user_name}_policy").and_return(true)
    response = VaultApi.client.delete_policy(user)
    expect(response).to eq(true)
  end

  def create_policy_rules
    capabilities = [:read]
    policy_rules = JSON.parse(policy_json(user))
    policy_rules[:path] ||= {}
    policy_rules[:path][secret_path.to_s] ||= {}
    policy_rules[:path][secret_path.to_s][:capabilities] = capabilities

    policy_rules
  end

  def update_policy_rules
    capabilities = [:read]
    policy_rules = JSON.parse(policy_json(user)).with_indifferent_access
    policy_rules[:path] ||= {}
    policy_rules[:path]["#{secret_path}/*"] ||= {}
    policy_rules[:path]["#{secret_path}/*"][:capabilities] = capabilities

    policy_rules
  end

  def policy_json(username)
    {
      path: {
        "secret/#{VaultApi.env}/#{username}/*" => {
          capabilities: %w[create read update delete list]
        },
        "#{VaultApi.secret_global_base_path}/*" => {
          capabilities: %w[read list]
        },
        :'secret/*' => {
          capabilities: %w[read list]
        },
        :'auth/token/lookup-self' => {
          capabilities: %w[read]
        },
        :'sys/capabilities-self' => {
          capabilities: %w[update read]
        },
        :'sys/mounts' => {
          capabilities: %w[read]
        },
        :'sys/auth' => {
          capabilities: %w[read]
        },
        "sys/policy/#{username}_policy" => {
          capabilities: %w[read]
        }
      }
    }.to_json
  end
end
