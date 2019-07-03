# frozen_string_literal: true

require 'vault'
module VaultApi
  module Connection
    # private

    def connection
      if token
        connection_obj = Vault::Client.new(address: address, token: token)
      else
        connection_obj = Vault::Client.new(address: address)
        connection_obj.auth.userpass(user, password)
      end
      connection_obj
    end
  end
end
