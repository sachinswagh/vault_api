# frozen_string_literal: true

require 'net/https'
require 'uri'
require 'securerandom'

# VaultApi::Client::Users
module VaultApi
  class Client
    module Users
      def create_user(username)
        secure_password = SecureRandom.hex(12)

        creds = {
          'password' => secure_password.to_s,
          'policies' => "#{username}_policy"
        }
        uri = URI.parse("#{VaultApi.address}/v1/#{VaultApi.auth_users_path}/#{username}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = creds.to_json
        request['X-Vault-Token'] = VaultApi.token.to_s

        http.request(request)

        creds
      end

      def create_user_with_secret(username)
        users = VaultApi.list(VaultApi.auth_users_path)

        if users.include? username.to_s
          puts "Vault user '#{username}' already exists."
          # exit 1
        else
          create_initial_user_policy(username)
          creds = create_user(username)
          add_secrets_to_user_from_global(username)

          creds
        end
      end

      def add_secrets_to_user_from_global(username)
        global_path = VaultApi.secret_global_base_path
        secrets = VaultApi.list(global_path)

        secrets.each do |filename|
          path_admin = "#{global_path}/#{filename}"
          data = VaultApi.read(path_admin).data
          user_path = "secret/#{VaultApi.env}/#{username}/#{filename}"
          VaultApi.write(user_path, data)
        end
      end

      def delete_user(username)
        VaultApi.delete("/#{VaultApi.auth_users_path}/#{username}")
        delete_policy(username)
        delete_path(VaultApi.secret_user_base_path(username))
      end
    end
  end
end
