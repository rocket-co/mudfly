require 'json'
require 'mudfly/request'

module Mudfly
  class Client

    def self.analyze(url, strategy: :test)

      unless [:desktop, :mobile, :test].include?(strategy)
        raise ArgumentError.new('Invalid strategy, only :desktop and :mobile are allowed.')
      end

      request_url = 'runPagespeed'

      query_string = {
        :url      => url,
        :strategy => strategy
      }

      if strategy == :test
        raw_response_body = File.read("#{Mudfly.root}/sample.json")
      else
        raw_response_body = Request.get(request_url, query_string)
      end
      response_body = JSON.parse raw_response_body

      report = OpenStruct.new

      report.response_code = response_body['responseCode']
      report.title         = response_body['title']
      report.score         = response_body['ruleGroups']['SPEED']['score']
      report.kind          = response_body['kind']
      report.id            = response_body['id']

      if response_body.has_key? "screenshot"
        report.screenshot = response_body['screenshot']['data']
      end

      report.stats = OpenStruct.new(
        :resources_number            => response_body['pageStats']['numberResources'],
        :hosts_number                => response_body['pageStats']['numberHosts'],
        :total_request_bytes         => response_body['pageStats']['totalRequestBytes'],
        :static_resources_number     => response_body['pageStats']['numberStaticResources'],
        :html_response_bytes         => response_body['pageStats']['htmlResponseBytes'],
        :css_response_bytes          => response_body['pageStats']['cssResponseBytes'],
        :image_response_bytes        => response_body['pageStats']['imageResponseBytes'],
        :javascript_response_bytes   => response_body['pageStats']['javascriptResponseBytes'],
        :javascript_resources_number => response_body['pageStats']['numberJsResources'],
        :css_resources_number        => response_body['pageStats']['numberCssResources'],
        :other_response_bytes        => response_body['pageStats']['otherResponseBytes']
      )

      report.rules = response_body['formattedResults']['ruleResults'].values.each.inject([]) do |rules, rule_data|
        temp_rule = OpenStruct.new(
          :name   => rule_data['localizedRuleName'],
          :score  => rule_data['ruleScore'],
          :impact => rule_data['ruleImpact'],
          :groups => rule_data['groups']
        )

        if rule_data.has_key? "summary"
          temp_rule.summary = replace_args(rule_data["summary"]["format"], rule_data["summary"]["args"])
        end

        if rule_data.has_key? 'urlBlocks'
          links = []
          rule_data["urlBlocks"].each do |url_block|
            if url_block.has_key? 'urls'
              url_block["urls"].each do |url|
                links << replace_args(url["result"]["format"], url["result"]["args"])
              end
            else
              if url_block.has_key? 'header'
                result = url_block["header"]
              elsif url_block.has_key? 'result'
                result = url_block["result"]
              end

              if result.present?
                links << replace_args(result["format"], result["args"])
              end
            end
          end

          temp_rule.links = links
        end

        rules << temp_rule
      end

      report.version = OpenStruct.new(
        :major => response_body['version']['major'],
        :minor => response_body['version']['minor']
      )

      report
    end # def

    def self.replace_args(message, args)
      if args.present?
        args.each_with_index do |arg, i|
          if Mudfly.version == :v1
            message.sub!("$#{i+1}", arg["value"])
          elsif Mudfly.version == :v2
            case arg["type"]
            when 'LINK', 'HYPERLINK'
              value = arg["value"]
              message.sub!("{{BEGIN_LINK}}", "<a href='#{value}'>")
              message.sub!("{{END_LINK}}", "</a>")
            else
              if arg.has_key? 'key'
                message.sub!("{{" + arg["key"] + "}}", arg["value"])
              else
                message += " - " + arg["value"]
              end
            end
          end
        end
      end

      message
    end # def

  end # Class
end # Module
