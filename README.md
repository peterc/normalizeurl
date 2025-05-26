# NormalizeURL

A Ruby library for normalizing URLs by removing tracking parameters, session IDs, and other extraneous elements whilst preserving important parameters. **NormalizeURL** creates a canonical representation of URLs that can be used for deduplication, caching keys, or comparison purposes.

> **Note:** Output URLs may not always be functional or clickable. The primary use case is generating consistent, comparable URL strings rather than ensuring URLs remain navigable.

---

## Installation

You know the drill:

```ruby
gem 'normalizeurl'   # in Gemfile
$ bundle install
$ gem install normalizeurl
```

## Basic Usage

```ruby
require 'normalizeurl'

# Simple normalization
url = "https://example.com/page?utm_source=google&utm_medium=cpc&id=123"
normalized = Normalizeurl.normalize(url)
# => "https://example.com/page?id=123"
```

```ruby
# Remove tracking parameters whilst preserving important ones
youtube_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&utm_source=twitter&t=42"
normalized = Normalizeurl.normalize(youtube_url)
# => "https://youtube.com/watch?t=42&v=dQw4w9WgXcQ"
```

NormalizeURL accepts various options to customize normalization:

```ruby
options = {
  remove_tracking_params: true,    # Remove UTM and other tracking parameters
  remove_trailing_slash: true,     # Remove trailing slashes from paths
  downcase_hostname: true,         # Convert hostname to lowercase
  remove_www: false,               # Remove 'www.' prefix from hostname
  remove_fragment: true,           # Remove URL fragments (#section)
  custom_tracking_params: [],      # Additional tracking parameters to remove
  preserve_params: {}              # Domain-specific parameters to preserve
}

normalized = Normalizeurl.normalize(url, options)
```

## Examples

...

## License
The gem is available as open source under the terms of the MIT License.
