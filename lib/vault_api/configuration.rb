# frozen_string_literal: true

module VaultApi
  module Configuration
    VALID_OPTIONS_KEYS = %i[
      address
      token
      user
      password
      env

      logger
    ].freeze

    # Use the default Faraday adapter.
    # DEFAULT_ADAPTER = Faraday.default_adapter

    # By default use the main api URL.
    DEFAULT_ADDRESS = ''

    attr_accessor *VALID_OPTIONS_KEYS

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    def options
      VALID_OPTIONS_KEYS.each_with_object({}) do |key, option|
        option[key] = send(key)
      end
    end

    # When this module is extended, reset all settings.
    def self.extended(base)
      base.reset
    end

    # Reset all configuration settings to default values.
    def reset
      self.address = DEFAULT_ADDRESS
      # self.adapter  = DEFAULT_ADAPTER
    end
  end
end
