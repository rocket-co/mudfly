require 'faraday'

require 'mudfly/error/bad_request'
require 'mudfly/error/forbidden'
require 'mudfly/error/service_unavailable'
require 'mudfly/error/internal_server_error'

module Mudfly

  module Response

    class HttpException < Faraday::Response::Middleware

      def on_complete(response)

        case response[:status].to_i

          when 400; raise Mudfly::Error::BadRequest.new(response[:body])

          when 403; raise Mudfly::Error::Forbidden.new(response[:body])

          when 500; raise Mudfly::Error::InternalServerError.new('Something gone wrong')

          when 503; raise Mudfly::Error::ServiceUnavailable.new('Impossible to handle the request')

        end

      end

    end # HttpException

  end # Response

end # Mudfly