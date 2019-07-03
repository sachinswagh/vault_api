# frozen_string_literal: true

module VaultApi
  class Error < StandardError
    def initialize(e)
      @wrapped_exception = nil

      if e.respond_to?(:backtrace)
        super(e.message)
        @wrapped_exception = e
      else
        super(e.to_s)
      end
    end

    def backtrace
      if @wrapped_exception
        @wrapped_exception.backtrace
      else
        super
      end
    end

    def inspect
      inner = ''
      inner << " wrapped=#{@wrapped_exception.inspect}" if @wrapped_exception
      inner << " #{super}" if inner.empty?
      %(#<#{self.class}#{inner}>)
    end
  end

  class ConnectionError < Error; end
  class AuthorizationError < Error; end
  class BadRequestError < Error; end
  class RecordNotFoundError < Error; end

  class TimeoutError < Error; end
  class NotFoundError < Error; end
  class SSLError < Error; end
  class ParseError < Error; end
  class UnauthorizedError < Error; end

  %i[Error
     ConnectionError AuthorizationError BadRequestError RecordNotFoundError
     TimeoutError NotFoundError SSLError ParseError UnauthorizedError].each do |const|
    Error.const_set(const, VaultApi.const_get(const))
  end
end
