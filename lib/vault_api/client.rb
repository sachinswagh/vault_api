# frozen_string_literal: true

require File.expand_path('api', __dir__)

module VaultApi
  # Wrapper for the VaultApi REST API.
  class Client < API
    Dir[File.expand_path('client/*.rb', __dir__)].each { |f| require f }

    include VaultApi::Client::Paths
    include VaultApi::Client::Users
    include VaultApi::Client::Entries
    include VaultApi::Client::Secrets
    include VaultApi::Client::Policies
  end
end
