# frozen_string_literal: true

module VaultApi
  module Request
    def list(params)
      request(:list, params)
    end

    def read(params)
      request(:read, params)
    end

    def write(path, config)
      request(:write, path, config)
    end

    def delete(params)
      request(:delete, params)
    end

    def policy(params)
      request_sys(:policy, params)
    end

    def put_policy(params, rules)
      request_sys(:put_policy, params, rules)
    end

    def delete_policy(params)
      request_sys(:delete_policy, params)
    end

    private

    def request(method, *params)
      begin
        response = case method
                   when :write
                     connection.logical.send(method, params[0], params[1])
                   else
                     connection.logical.send(method, params[0])
                   end
      rescue StandardError => e
        raise Error, e
      end

      response
    end

    def request_sys(method, *params)
      begin
        response = case method
                   when :put_policy
                     connection.sys.send(method, params[0], params[1])
                   else
                     connection.sys.send(method, params[0])
                   end
      rescue StandardError => e
        raise Error, e
      end

      response
    end
  end
end
