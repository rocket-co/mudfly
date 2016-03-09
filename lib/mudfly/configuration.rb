require "mudfly/version"

module Mudfly

  module Configuration

    VALID_CONFIGURATION_KEYS = [:api_key, :user_agent, :endpoint, :locale]

    DEFAULT_API_KEY    = nil
    DEFAULT_USER_AGENT = "Mudfly Ruby Gem #{Mudfly::VERSION}"
    DEFAULT_ENDPOINT   = 'https://www.googleapis.com/pagespeedonline/v1/'
    DEFAULT_LOCALE     = 'en_US'


    attr_accessor *VALID_CONFIGURATION_KEYS

    def self.extended(base)

      base.api_key    = DEFAULT_API_KEY
      base.user_agent = DEFAULT_USER_AGENT
      base.endpoint   = DEFAULT_ENDPOINT
      base.locale     = DEFAULT_LOCALE
    
    end

    # Allow block configuration

    def configure

      yield self

    end

  end # Configuration

end # Mudfly