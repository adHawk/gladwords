# frozen_string_literal: true

module AdwordsApi
  class Api
    def freeze(*_args)
      true
    end
  end
end

module AdwordsHelpers
  # This is a test account, i.e. no real ad spend
  API_CONFIG = {
    authentication: {
      method: 'OAuth2',
      oauth2_client_id: '191191759012-uflljs7ckudnq4pl14lrkogkej2rodvm' \
                        '.apps.googleusercontent.com',
      oauth2_client_secret: 'zDil4XMnvtjeQqBpbJVEbS7d',
      developer_token: 'rLHiiXnn-XSm4AwE8Ni6Tw',
      client_customer_id: '9919697176',
      user_agent: 'gladwords',
      oauth2_token: {
        refresh_token: '1/QEmJJudQcsw8CMfBU2VDZrhJaRVKQ8TjdVkvRYuZgFg',
        expires_in: 0
      }
    },
    service: {
      environment: 'PRODUCTION'
    }
  }.freeze

  def gimme_adwords
    @gimme_adwords ||= begin
                         adwords = AdwordsApi::Api.new(API_CONFIG)
                         if Dir.exist?('log')
                           adwords.logger = Logger.new('log/test.log')
                         end
                         adwords
                       end
  end
end
