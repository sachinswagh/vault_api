# frozen_string_literal: true

require File.expand_path('request', __dir__)
require File.expand_path('connection', __dir__)
require File.expand_path('configuration', __dir__)

module VaultApi
  class API
    include Request
    include Connection

    attr_accessor *Configuration::VALID_OPTIONS_KEYS

    def initialize(options = {})
      options = VaultApi.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    def config
      conf = {}
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        conf[key] = send key
      end
      conf
    end
  end
end
