# frozen_string_literal: true

require 'yaml'

# VaultApi::Client::Secrets
module VaultApi
  class Client
    module Secrets
      def secrets(user_name = nil)
        VaultApi.list(VaultApi.secret_base_path(user_name))
      end

      def read_secret(config_name, user_name = nil)
        VaultApi.read("#{VaultApi.secret_base_path(user_name)}/#{config_name}").data
      end

      def add_secret(config_file_path, user_name = nil)
        file_basename = File.basename(config_file_path, '.yml')
        secret_path = "#{VaultApi.secret_base_path(user_name)}/#{file_basename}"

        output_json = JSON.dump(YAML.load_file(config_file_path))
        obj = JSON.parse(output_json)
        content = obj[VaultApi.env.to_s]
        VaultApi.write(secret_path, content)
      end

      def update_secret(config_file_path, user_name = nil)
        add_secret(config_file_path, user_name) # overwrites existing file
      end

      def upload_secrets(config_folder_path, user_name = nil)
        Dir.chdir config_folder_path
        Dir.glob('*.yml').each do |file|
          add_secret("#{config_folder_path}/#{file}", user_name)
        end
      end

      def delete_secret(config_name, user_name = nil)
        VaultApi.delete("#{VaultApi.secret_base_path(user_name)}/#{config_name}")
      end
    end
  end
end
