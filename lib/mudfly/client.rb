require 'json'
require 'mudfly/request'

module Mudfly
  class Client

    def self.analyze(url, strategy: :desktop)

      unless [:desktop, :mobile, :test_desktop, :test_mobile].include?(strategy)
        raise ArgumentError.new('Invalid strategy, only :desktop and :mobile are allowed.')
      end

      request_url = 'runPagespeed'

      query_string = {
        :url      => url,
        :strategy => strategy
      }

      if strategy == :test_desktop
        raw_response_body = File.read("#{Mudfly.root}/sample_desktop.json")
      elsif strategy == :test_mobile
        raw_response_body = File.read("#{Mudfly.root}/sample_mobile.json")
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

      report.stats = OpenStruct.new

      report.stats.resources_number            = response_body['pageStats']['numberResources'].present? ? response_body['pageStats']['numberResources'] : 0
      report.stats.hosts_number                = response_body['pageStats']['numberHosts'].present? ? response_body['pageStats']['numberHosts'] : 0
      report.stats.total_request_bytes         = response_body['pageStats']['totalRequestBytes'].present? ? response_body['pageStats']['totalRequestBytes'] : 0
      report.stats.static_resources_number     = response_body['pageStats']['numberStaticResources'].present? ? response_body['pageStats']['numberStaticResources'] : 0
      report.stats.html_response_bytes         = response_body['pageStats']['htmlResponseBytes'].present? ? response_body['pageStats']['htmlResponseBytes'] : 0
      report.stats.css_response_bytes          = response_body['pageStats']['cssResponseBytes'].present? ? response_body['pageStats']['cssResponseBytes'] : 0
      report.stats.image_response_bytes        = response_body['pageStats']['imageResponseBytes'].present? ? response_body['pageStats']['imageResponseBytes'] : 0
      report.stats.javascript_response_bytes   = response_body['pageStats']['javascriptResponseBytes'].present? ? response_body['pageStats']['javascriptResponseBytes'] : 0
      report.stats.javascript_resources_number = response_body['pageStats']['numberJsResources'].present? ? response_body['pageStats']['numberJsResources'] : 0
      report.stats.css_resources_number        = response_body['pageStats']['numberCssResources'].present? ? response_body['pageStats']['numberCssResources'] : 0
      report.stats.other_response_bytes        = response_body['pageStats']['otherResponseBytes'].present? ? response_body['pageStats']['otherResponseBytes'] : 0

      puts "report.stats #{report.stats}"

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
