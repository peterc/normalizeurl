require_relative "normalizeurl2025/version"
require_relative "normalizeurl2025/normalizer"

module Normalizeurl2025
  class Error < StandardError; end

  def self.normalize(url, options = {})
    Normalizer.new(options).normalize(url)
  end
end
