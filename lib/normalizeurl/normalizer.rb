# frozen_string_literal: true

require 'uri'

module Normalizeurl
  class Normalizer
    # Parameters that are commonly used for tracking and should be removed
    DEFAULT_TRACKING_PARAMS = %w[
      utm_source utm_medium utm_campaign utm_term utm_content
      utm_name utm_cid utm_reader utm_viz_id utm_pubreferrer utm_swu
      gclid fbclid msclkid
      _ga _gl
      mc_cid mc_eid
      PHPSESSID JSESSIONID ASPSESSIONID
      sid sessionid session_id
      ref referer referrer
      source src
      campaign
      yclid
      _openstat
      rb_clickid
      s_cid
      vero_conv vero_id
      wickedid
      oly_anon_id oly_enc_id
      __s
      subscriber_id
      ig_rid
    ].freeze

    # Parameters that should be preserved for certain domains
    PRESERVE_PARAMS = {
      'youtube.com' => %w[v t list index],
      'youtu.be' => %w[v t],
      'vimeo.com' => %w[h_original],
      'amazon.com' => %w[keywords tag],
      'amazon.co.uk' => %w[keywords tag],
      'ebay.com' => %w[hash],
      'ebay.co.uk' => %w[hash],
      'twitter.com' => %w[s],
      'github.com' => %w[tab],
      'stackoverflow.com' => %w[answertab],
      'google.com' => %w[q],
      'google.co.uk' => %w[q],
      'bing.com' => %w[q],
      'duckduckgo.com' => %w[q]
    }.freeze

    def initialize(options = {})
      @remove_tracking_params = options.fetch(:remove_tracking_params, true)
      @remove_trailing_slash = options.fetch(:remove_trailing_slash, true)
      @downcase_hostname = options.fetch(:downcase_hostname, true)
      @remove_www = options.fetch(:remove_www, false)
      @remove_fragment = options.fetch(:remove_fragment, true)
      @custom_tracking_params = options.fetch(:custom_tracking_params, [])
      @preserve_params = options.fetch(:preserve_params, {})
    end

    def normalize(url)
      return nil if url.nil? || url.strip.empty?

      begin
        uri = URI.parse(url.strip)
      rescue URI::InvalidURIError
        return url
      end

      # Only process HTTP/HTTPS URLs
      return url unless %w[http https].include?(uri.scheme&.downcase)

      normalize_scheme!(uri)
      normalize_hostname!(uri)
      normalize_path!(uri)
      normalize_query!(uri)
      normalize_fragment!(uri)

      uri.to_s
    end

    private

    def normalize_scheme!(uri)
      uri.scheme = uri.scheme.downcase if uri.scheme
    end

    def normalize_hostname!(uri)
      return unless uri.host

      if @downcase_hostname
        uri.host = uri.host.downcase
      end

      if @remove_www && uri.host.start_with?('www.')
        uri.host = uri.host[4..-1]
      end
    end

    def normalize_path!(uri)
      return unless uri.path

      # Remove trailing slash unless it's the root path
      if @remove_trailing_slash && uri.path != '/' && uri.path.end_with?('/')
        uri.path = uri.path.chomp('/')
      end

      # Ensure root path is present
      uri.path = '/' if uri.path.empty?
    end

    def normalize_query!(uri)
      return unless uri.query && @remove_tracking_params

      params = URI.decode_www_form(uri.query)
      
      # Get domain-specific parameters to preserve
      domain_preserve_params = get_preserve_params_for_domain(uri.host)
      
      # Filter out tracking parameters
      filtered_params = params.reject do |key, _value|
        should_remove_param?(key, domain_preserve_params)
      end

      if filtered_params.empty?
        uri.query = nil
      else
        # Sort parameters for consistency
        uri.query = URI.encode_www_form(filtered_params.sort)
      end
    end

    def normalize_fragment!(uri)
      uri.fragment = nil if @remove_fragment
    end

    def get_preserve_params_for_domain(host)
      return [] unless host

      # Check for exact domain match first
      preserved = PRESERVE_PARAMS[host] || []
      
      # Check for subdomain matches
      PRESERVE_PARAMS.each do |domain, params|
        if host.end_with?(".#{domain}")
          preserved.concat(params)
        end
      end

      # Add custom preserve params for this domain
      if @preserve_params[host]
        preserved.concat(@preserve_params[host])
      end

      preserved.uniq
    end

    def should_remove_param?(param_name, preserve_params)
      param_lower = param_name.downcase
      
      # Don't remove if it's in the preserve list
      return false if preserve_params.any? { |p| p.downcase == param_lower }
      
      # Remove if it's a tracking parameter
      tracking_params = DEFAULT_TRACKING_PARAMS + @custom_tracking_params
      tracking_params.any? { |tp| tp.downcase == param_lower }
    end
  end
end
