# frozen_string_literal: true

# VaultApi::Client::Entries
module VaultApi
  class Client
    module Entries
      def entries(secret_name, user_name = nil)
        read_secret(secret_name, user_name)
      end

      def add_entry(secret_name, key, value, user_name = nil)
        process_entry(secret_name, key, value, user_name)
      end

      def read_entry(secret_name, key, user_name = nil)
        path = config_path(secret_name, user_name)
        config = VaultApi.read(path).data
        config[key.to_sym]
      end

      def update_entry(secret_name, key, value, user_name = nil)
        process_entry(secret_name, key, value, user_name)
      end

      def delete_entry(secret_name, key, user_name = nil)
        config = VaultApi.read_secret(secret_name, user_name)
        config = config.dup if config.frozen? # read
        config.delete(key.to_sym)
        path = config_path(secret_name)
        VaultApi.write(path, config) # write
      end

      def clone_entry(secret_name, key, target)
        if [secret_name, key, target].any?(&:blank?)
          puts 'secret_name can\'t be blank'
        elsif key.blank?
          puts 'key can\'t be blank'
        elsif target.blank?
          puts 'target can\'t be blank'
        else
          if !target.is_a?(Array) && target.to_sym == :all
            clone_entry_to_all_users(secret_name, key)
          elsif target.is_a?(String) || target.is_a?(Symbol)
            clone_entry_to_target_users(secret_name, key, [target])
          elsif target.is_a?(Array)
            clone_entry_to_target_users(secret_name, key, target)
          else
            'Invalid Target'
          end
        end
      end

      private

      def clone_entry_to_users(secret_name, key, users)
        secret = VaultApi.read_secret(secret_name)
        secret = secret.dup.symbolize_keys

        if (key.is_a?(String) && key != 'all') || (key.is_a?(Symbol) && key != :all)
          clone_single_entry_to_users(secret_name, key, secret, users)
        elsif key.is_a?(Array) || key.to_sym == :all
          clone_multiple_entries_to_users(secret_name, key, secret, users)
        end
      end

      def clone_single_entry_to_users(secret_name, key, secret, users)
        response = {}

        value = secret[key.to_sym]
        users.map do |user_name|
          # puts "single: user_name: #{user_name}, key: #{key}, #{value}"
          response[user_name] ||= {}
          entry_response = VaultApi.add_entry(secret_name, key, value, user_name)
          response[user_name][key.to_sym] = entry_response
        end

        # puts "response: #{response}"

        response
      end

      def clone_multiple_entries_to_users(secret_name, key, secret, users)
        response = {}
        keys = if key.is_a?(Array)
                 key
               else
                 (key.to_sym == :all ? secret.keys : [])
        end

        users.map do |user_name|
          response[user_name] ||= {}

          keys.each do |k|
            v = secret[k.to_sym]
            entry_response = VaultApi.add_entry(secret_name, k, v, user_name)
            response[user_name][k.to_sym] = entry_response
          end
        end

        response
      end

      def clone_entry_to_all_users(secret_name, key)
        users = VaultApi.list(VaultApi.auth_users_path)
        clone_entry_to_users(secret_name, key, users)
      end

      def clone_entry_to_target_users(secret_name, key, targets)
        targets = targets.map(&:to_sym)
        users = VaultApi.list(VaultApi.auth_users_path) # auth_users_path
        users = users.map(&:to_sym)
        valid_users = (users & targets) # extracts valid target users.
        clone_entry_to_users(secret_name, key, valid_users)
      end

      def config_path(secret_name, user_name = nil)
        "#{VaultApi.secret_base_path(user_name)}/#{secret_name}"
      end

      def process_entry(secret_name, key, value, user_name = nil)
        config = VaultApi.read_secret(secret_name, user_name) # read
        config = config.dup if config.frozen?
        config[key.to_sym] = value                 # merge
        path = config_path(secret_name, user_name)
        VaultApi.write(path, config)               # write
      end
    end
  end
end
