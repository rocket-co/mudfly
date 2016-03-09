require 'json'

require 'mudfly/request'

module Mudfly

  class Client

    def self.analyze(url, strategy: :desktop)

      unless [:desktop, :mobile].include?(strategy)

        raise ArgumentError.new('Invalid strategy, only :desktop and :mobile are allowed.')

      end

      request_url = 'runPagespeed'

      query_string = {

        :url      => url,
        :strategy => strategy

      }

      response_body = JSON.parse( Request.get(request_url, query_string) )

      report = OpenStruct.new

      report.response_code = response_body['responseCode']
      report.title         = response_body['title']
      report.score         = response_body['score']
      report.kind          = response_body['kind']
      report.id            = response_body['id']

      report.stats = OpenStruct.new({

        :resources_number            => response_body['pageStats']['numberResources'],
        :hosts_number                => response_body['pageStats']['numberHosts'],
        :total_request_bytes         => response_body['pageStats']['totalRequestBytes'],
        :static_resources_number     => response_body['pageStats']['numberStaticResources'],
        :html_response_bytes         => response_body['pageStats']['htmlResponseBytes'],
        :css_response_bytes          => response_body['pageStats']['cssResponseBytes'],
        :image_response_bytes        => response_body['pageStats']['imageResponseBytes'],
        :javascript_response_bytes   => response_body['pageStats']['javascriptResponseBytes'],
        :javascript_resources_number => response_body['pageStats']['numberJsResources'],
        :css_resources_number        => response_body['pageStats']['numberCssResources']

      })

      report.rules = response_body['formattedResults']['ruleResults'].values.each.inject([]) do |rules, rule_temp|

        rules << OpenStruct.new({

          :name   => rule_temp['localizedRuleName'],
          :score  => rule_temp['ruleScore'],
          :impact => rule_temp['ruleImpact']

        })

      end

      report.version = OpenStruct.new({

        :major => response_body['version']['major'],
        :minor => response_body['version']['minor']

      })

      return report

    end

  end

end