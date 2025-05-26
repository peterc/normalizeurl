# frozen_string_literal: true

require_relative "normalizeurl/version"
require_relative "normalizeurl/normalizer"

module Normalizeurl
  class Error < StandardError; end

  def self.normalize(url, options = {})
    Normalizer.new(options).normalize(url)
  end
end
