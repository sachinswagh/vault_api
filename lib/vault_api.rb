# frozen_string_literal: true

require 'pry'
require 'active_support/all'

require 'vault_api/api'
require 'vault_api/client'
require 'vault_api/version'

require File.expand_path('vault_api/configuration', __dir__)
require File.expand_path('vault_api/api', __dir__)
require File.expand_path('vault_api/client', __dir__)
require File.expand_path('vault_api/error', __dir__)

module VaultApi
  extend Configuration
  # Alias for VaultApi::Client.new
  # @return [VaultApi::Client]
  def self.client(options = {})
    VaultApi::Client.new(options)
  end

  # Delegate to VaultApi::Client
  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)

    client.send(method, *args, &block)
  end

  def self.secret_base_path(user_name = nil)
    if user_name.present?
      secret_user_base_path(user_name)
    elsif VaultApi.user.present? # && VaultApi.password.present?
      secret_user_base_path
    elsif VaultApi.token.present?
      secret_global_base_path
    else
      ''
    end
  end

  def self.secret_global_base_path
    "secret/global/#{VaultApi.env}"
  end

  def self.secret_user_base_path(user_name = nil)
    if user_name.present?
      "secret/#{VaultApi.env}/#{user_name}"
    else
      "secret/#{VaultApi.env}/#{VaultApi.user}"
    end
  end

  def self.auth_users_path
    'auth/userpass/users'
  end
end
