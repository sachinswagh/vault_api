# frozen_string_literal: true

module VaultApi
  class Client
    module Paths
      def delete_path(vault_secret_path)
        config_data = VaultApi.list(vault_secret_path.to_s)

        if config_data.present?
          config_data.to_a.each do |file_name|
            VaultApi.delete("#{vault_secret_path}/#{file_name}")
          end
        end

        VaultApi.delete(vault_secret_path.to_s)
      end
    end
  end
end
