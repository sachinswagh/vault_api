# frozen_string_literal: true

require 'spec_helper'
require 'vault_api/client/entries'

describe 'VaultApi::Client::Entries' do
  let (:address)  { 'https://vault-server.test.com' }
  let (:user)     { 'swagh' }
  let (:user2)    { 'swagh2' }
  let (:user3)    { 'swagh3' }
  let (:password) { 'test-password' }
  let (:env)      { 'development' }
  let (:token)    { 'test-token' }

  let (:entries)  { load_entries }
  let (:global_entries) { load_entries('/global') }
  let (:secret_base_path) { VaultApi.secret_base_path(user) }
  let (:secret_global_base_path) { VaultApi.secret_global_base_path }
  let (:secret_name)  { 'awstest' }
  let (:secret_path)  { "#{secret_base_path}/#{secret_name}" }
  let (:global_secret_path) { "#{secret_global_base_path}/#{secret_name}" }

  before do
    VaultApi.configure do |config|
      config.address = ''
      config.user = user
      config.password = password
      # config.token = token
      config.env = env
    end
  end

  it 'list entries' do
    expect(VaultApi).to receive(:read).with(secret_path).and_return(entries)
    response = VaultApi.entries(secret_name)
    expect(response[:activity_email_bucket]).to eq('my-project-emails')
  end

  it 'add_entry' do
    key = 'key4'
    value = 'value4'
    entries_hash = entries.data
    entries_hash[key.to_sym] = value

    expect(VaultApi).to receive(:read).with(secret_path).and_return(entries)
    expect(VaultApi).to receive(:write).with(secret_path, entries_hash).and_return(true)
    response = VaultApi.add_entry(secret_name, key, value)
    expect(response).to eq(true)
  end

  it 'read_entry' do
    expect(VaultApi).to receive(:read).with(secret_path).and_return(entries)
    response = VaultApi.read_entry(secret_name, 'activity_email_bucket')
    expect(response).to eq('my-project-emails')
  end

  it 'update_entry' do
    key = 'key4'
    value = 'value4'
    expect(VaultApi).to receive(:read).with(secret_path).and_return(entries)

    entries_hash = entries.data
    entries_hash[key.to_sym] = value

    expect(VaultApi).to receive(:write).with(secret_path, entries_hash).and_return(true)
    response = VaultApi.update_entry(secret_name, key, value)
    expect(response).to eq(true)
  end

  it 'delete_entry' do
    key = 'activity_email_bucket'
    entries_hash = entries.data
    entries_hash.delete(key.to_sym)
    expect(VaultApi).to receive(:read).with(secret_path).and_return(entries)
    expect(VaultApi).to receive(:write).with(secret_path, entries_hash).and_return(true)
    response = VaultApi.delete_entry(secret_name, key)
    expect(response).to eq(true)
  end

  describe '#clones' do
    before do
      VaultApi.configure do |config|
        config.address = ''
        config.user = ''
        config.password = ''
        config.token = token
        config.env = env
      end
    end

    context 'single_entry' do
      it 'for_single_user' do
        users = [user]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)

        key = 'key1'
        global_entries_hash = global_entries.data
        value = global_entries_hash[key.to_sym]

        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)

        expect(VaultApi).to receive(:read).with(secret_path).and_return(entries)

        entries_hash = entries.data
        entries_hash[key.to_sym] = value

        expect(VaultApi).to receive(:write).with(secret_path, entries_hash).and_return(true)

        response = VaultApi.clone_entry(secret_name, key, user)
        expect(response.class).to be(Hash)
        expect(response[user.to_sym][key.to_sym]).to eq(true)
      end

      it 'for_multiple_users' do
        users = [user, user2]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)
        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)
        key = 'key1'
        global_entries_hash = global_entries.data
        value = global_entries_hash[key.to_sym]

        users.each do |usr|
          secrt_pth = "#{VaultApi.secret_base_path(usr)}/#{secret_name}"
          expect(VaultApi).to receive(:read).with(secrt_pth).and_return(entries)
          entries_hash = entries.data
          entries_hash[key.to_sym] = value
          expect(VaultApi).to receive(:write).with(secrt_pth, entries_hash).and_return(true)
        end

        response = VaultApi.clone_entry(secret_name, key, users)
        expect(response.class).to be(Hash)
        users.each do |usr|
          expect(response[usr.to_sym][key.to_sym]).to eq(true)
        end
      end

      it 'for_all_users' do
        users = [user, user2, user3]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)
        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)
        key = 'key1'
        global_entries_hash = global_entries.data
        value = global_entries_hash[key.to_sym]

        users.each do |usr|
          secrt_pth = "#{VaultApi.secret_base_path(usr)}/#{secret_name}"
          expect(VaultApi).to receive(:read).with(secrt_pth).and_return(entries)
          entries_hash = entries.data
          entries_hash[key.to_sym] = value
          expect(VaultApi).to receive(:write).with(secrt_pth, entries_hash).and_return(true)
        end

        response = VaultApi.clone_entry(secret_name, key, :all)
        expect(response.class).to be(Hash)

        users.each do |usr|
          expect(response[usr][key.to_sym]).to eq(true)
        end
      end
    end

    context 'multiple_entries' do
      it 'for_single_user' do
        users = [user]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)
        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)
        global_entries_hash = global_entries.data

        keys = %w[key1 key2]

        keys.each do |key|
          value = global_entries_hash[key.to_sym]

          expect(VaultApi).to receive(:read).with(secret_path).and_return(entries)

          entries_hash = entries.data
          entries_hash[key.to_sym] = value
          expect(VaultApi).to receive(:write).with(secret_path, entries_hash).and_return(true)
        end

        response = VaultApi.clone_entry(secret_name, keys, user)
        expect(response.class).to be(Hash)

        keys.each do |key|
          expect(response[user.to_sym][key.to_sym]).to eq(true)
        end
      end

      it 'for_multiple_users' do
        users = [user, user2]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)
        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)
        global_entries_hash = global_entries.data

        keys = %w[key1 key2]

        keys.each do |key|
          value = global_entries_hash[key.to_sym]

          users.each do |usr|
            secrt_pth = "#{VaultApi.secret_base_path(usr)}/#{secret_name}"
            expect(VaultApi).to receive(:read).with(secrt_pth).and_return(entries)
            entries_hash = entries.data
            entries_hash[key.to_sym] = value
            expect(VaultApi).to receive(:write).with(secrt_pth, entries_hash).and_return(true)
          end
        end

        response = VaultApi.clone_entry(secret_name, keys, users)
        expect(response.class).to be(Hash)

        keys.each do |key|
          users.each do |usr|
            expect(response[usr.to_sym][key.to_sym]).to eq(true)
          end
        end
      end

      it 'for_all_users' do
        users = [user, user2, user3]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)
        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)
        global_entries_hash = global_entries.data

        keys = %w[key1 key2]

        keys.each do |key|
          value = global_entries_hash[key.to_sym]

          users.each do |usr|
            secrt_pth = "#{VaultApi.secret_base_path(usr)}/#{secret_name}"
            expect(VaultApi).to receive(:read).with(secrt_pth).and_return(entries)
            entries_hash = entries.data
            entries_hash[key.to_sym] = value
            expect(VaultApi).to receive(:write).with(secrt_pth, entries_hash).and_return(true)
          end
        end

        response = VaultApi.clone_entry(secret_name, keys, users)
        expect(response.class).to be(Hash)

        keys.each do |key|
          users.each do |usr|
            expect(response[usr.to_sym][key.to_sym]).to eq(true)
          end
        end
      end
    end

    context 'all_entries' do
      it 'for_single_user' do
        users = [user]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)
        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)

        global_entries_hash = global_entries.data
        all_keys = global_entries_hash.keys

        all_keys.each do |key|
          value = global_entries_hash[key.to_sym]
          expect(VaultApi).to receive(:read).with(secret_path).and_return(entries)

          entries_hash = entries.data
          entries_hash[key.to_sym] = value
          expect(VaultApi).to receive(:write).with(secret_path, entries_hash).and_return(true)
        end

        response = VaultApi.clone_entry(secret_name, :all, user)

        expect(response.class).to be(Hash)
        all_keys.each do |key|
          expect(response[user.to_sym][key.to_sym]).to eq(true)
        end
      end

      it 'for_multiple_users' do
        users = [user, user2]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)
        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)
        global_entries_hash = global_entries.data

        keys = global_entries_hash.keys

        keys.each do |key|
          value = global_entries_hash[key.to_sym]

          users.each do |usr|
            secrt_pth = "#{VaultApi.secret_base_path(usr)}/#{secret_name}"
            expect(VaultApi).to receive(:read).with(secrt_pth).and_return(entries)
            entries_hash = entries.data
            entries_hash[key.to_sym] = value
            expect(VaultApi).to receive(:write).with(secrt_pth, entries_hash).and_return(true)
          end
        end

        response = VaultApi.clone_entry(secret_name, keys, users)
        expect(response.class).to be(Hash)

        keys.each do |key|
          users.each do |usr|
            expect(response[usr.to_sym][key.to_sym]).to eq(true)
          end
        end
      end

      it 'for_all_users' do
        users = [user, user2, user3]
        expect(VaultApi).to receive(:list).with(VaultApi.auth_users_path).and_return(users)
        expect(VaultApi).to receive(:read).with(global_secret_path).and_return(global_entries)
        global_entries_hash = global_entries.data

        keys = global_entries_hash.keys

        keys.each do |key|
          value = global_entries_hash[key.to_sym]

          users.each do |usr|
            secrt_pth = "#{VaultApi.secret_base_path(usr)}/#{secret_name}"
            expect(VaultApi).to receive(:read).with(secrt_pth).and_return(entries)
            entries_hash = entries.data
            entries_hash[key.to_sym] = value
            expect(VaultApi).to receive(:write).with(secrt_pth, entries_hash).and_return(true)
          end
        end

        response = VaultApi.clone_entry(secret_name, keys, users)
        expect(response.class).to be(Hash)

        keys.each do |key|
          users.each do |usr|
            expect(response[usr.to_sym][key.to_sym]).to eq(true)
          end
        end
      end
    end
  end

  def load_entries(global = '')
    config_file_path = File.expand_path("../../fixtures#{global}/secrets", __dir__)
    config_file_path = "#{config_file_path}/#{secret_name}.yml"
    output_json = JSON.dump(YAML.load_file(config_file_path))
    entries_hash = JSON.parse(output_json)[VaultApi.env].symbolize_keys
    OpenStruct.new(data: entries_hash)
  end
end
