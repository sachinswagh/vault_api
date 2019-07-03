# frozen_string_literal: true

# VaultApi::Client::Policies
module VaultApi
  class Client
    module Policies
      def create_initial_user_policy(username)
        puts "Creating #{username}_policy"
        if VaultApi.put_policy("#{username}_policy", policy_json(username))
          puts "Created #{username}_policy"
          true
        else
          false
        end
      end

      def read_policy(username)
        VaultApi.policy("#{username}_policy")
      end

      def create_policy(username, path = '', capabilities = [])
        policy_rules = {}
        policy_rules[:path] ||= {}
        policy_rules[:path][path.to_s] ||= {}
        policy_rules[:path][path.to_s][:capabilities] = capabilities
        VaultApi.put_policy("#{username}_policy", policy_rules.to_json)
      end

      def update_policy(username, path = '', capabilities = [])
        policy = VaultApi.policy("#{username}_policy")
        policy_rules = JSON.parse(policy.rules).with_indifferent_access
        policy_rules[:path][path.to_s] ||= {}
        policy_rules[:path][path.to_s][:capabilities] = capabilities
        VaultApi.put_policy("#{username}_policy", policy_rules.to_json)
      end

      def delete_policy(username)
        VaultApi.delete_policy("#{username}_policy")
      end

      private

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
  end
end
