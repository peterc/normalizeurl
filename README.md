# NormalizeURL 2025

A Ruby library for normalizing URLs by removing tracking parameters, session IDs, and other extraneous elements whilst preserving important parameters.

NormalizeURL 2025 creates a canonical representation of URLs that can be used for deduplication, caching keys, or comparison purposes and was developed initially to deduplicate URLs found in RSS feeds.

**Important**: The normalized URLs are intended for creating unique representations and may not always remain functional URLs.

## Installation

For your `Gemfile`:

```ruby
gem 'normalizeurl2025'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install normalizeurl2025

## Usage

### Basic Usage

```ruby
require 'normalizeurl2025'

# Simple normalization
url = "https://example.com/page?utm_source=google&utm_medium=cpc&id=123"
normalized = Normalizeurl2025.normalize(url)
# => "https://example.com/page?id=123"

# Remove tracking parameters whilst preserving important ones
youtube_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&utm_source=twitter&t=42"
normalized = Normalizeurl2025.normalize(youtube_url)
# => "https://youtube.com/watch?t=42&v=dQw4w9WgXcQ"
```

### Configuration Options

NormalizeURL 2025 accepts various options to customize the normalization behaviour:

```ruby
# Default options
options = {
  remove_tracking_params: true,    # Remove UTM and other tracking parameters
  remove_trailing_slash: true,     # Remove trailing slashes from paths
  downcase_hostname: true,         # Convert hostname to lowercase
  remove_www: false,               # Remove 'www.' prefix from hostname
  remove_fragment: true,           # Remove URL fragments (#section)
  custom_tracking_params: [],      # Additional tracking parameters to remove
  preserve_params: {}              # Domain-specific parameters to preserve
}

normalized = Normalizeurl2025.normalize(url, options)
```

### Examples

#### Removing Tracking Parameters

```ruby
# UTM parameters are removed
url = "https://example.com/article?utm_source=newsletter&utm_campaign=spring2024&id=456"
Normalizeurl2025.normalize(url)
# => "https://example.com/article?id=456"

# Google Click ID and Facebook Click ID are removed
url = "https://shop.example.com/product?gclid=abc123&fbclid=def456&product_id=789"
Normalizeurl2025.normalize(url)
# => "https://shop.example.com/product?product_id=789"

# Session IDs and tracking pixels are removed
url = "https://site.com/page?PHPSESSID=abc123&_ga=GA1.2.123456&content=article"
Normalizeurl2025.normalize(url)
# => "https://site.com/page?content=article"
```

#### Preserving Important Parameters

```ruby
# YouTube video parameters are preserved
url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&utm_source=email&t=120&list=PLxyz"
Normalizeurl2025.normalize(url)
# => "https://youtube.com/watch?list=PLxyz&t=120&v=dQw4w9WgXcQ"

# Amazon product parameters are preserved
url = "https://amazon.com/dp/B08N5WRWNW?tag=mysite-20&utm_source=blog&keywords=ruby"
Normalizeurl2025.normalize(url)
# => "https://amazon.com/dp/B08N5WRWNW?keywords=ruby&tag=mysite-20"

# Search engine queries are preserved
url = "https://google.com/search?q=ruby+gems&utm_source=referral&hl=en"
Normalizeurl2025.normalize(url)
# => "https://google.com/search?q=ruby+gems"
```

#### URL Structure Normalization

```ruby
# Hostname is lowercased and www is optionally removed
url = "HTTPS://WWW.EXAMPLE.COM/Path/?utm_source=email"
Normalizeurl2025.normalize(url)
# => "https://www.example.com/Path"

# Remove www prefix
url = "https://www.example.com/page?id=123"
Normalizeurl2025.normalize(url, remove_www: true)
# => "https://example.com/page?id=123"

# Trailing slashes are removed (except root)
url = "https://example.com/path/to/page/?utm_medium=social"
Normalizeurl2025.normalize(url)
# => "https://example.com/path/to/page?utm_medium=social"

# Fragments are removed by default
url = "https://example.com/page#section?utm_source=twitter"
Normalizeurl2025.normalize(url)
# => "https://example.com/page"

# Keep fragments if needed
url = "https://example.com/page#section?utm_source=twitter"
Normalizeurl2025.normalize(url, remove_fragment: false)
# => "https://example.com/page#section"
```

#### Query Parameter Sorting

```ruby
# Parameters are sorted alphabetically for consistency
url = "https://example.com/search?z=last&a=first&m=middle&utm_source=email"
Normalizeurl2025.normalize(url)
# => "https://example.com/search?a=first&m=middle&z=last"
```

#### Custom Configuration

```ruby
# Add custom tracking parameters to remove
options = {
  custom_tracking_params: ['my_tracker', 'internal_ref', 'campaign_id']
}
url = "https://example.com/page?my_tracker=abc&internal_ref=xyz&id=123&campaign_id=spring"
Normalizeurl2025.normalize(url, options)
# => "https://example.com/page?id=123"

# Preserve custom parameters for specific domains
options = {
  preserve_params: {
    'mysite.com' => ['special_param', 'user_pref'],
    'shop.example.com' => ['affiliate_id', 'discount_code']
  }
}
url = "https://mysite.com/page?special_param=value&utm_source=email&user_pref=dark"
Normalizeurl2025.normalize(url, options)
# => "https://mysite.com/page?special_param=value&user_pref=dark"

# Subdomain matching works automatically
url = "https://blog.mysite.com/post?special_param=test&utm_campaign=launch"
Normalizeurl2025.normalize(url, options)
# => "https://blog.mysite.com/post?special_param=test"
```

#### Error Handling

```ruby
# Invalid URLs are returned unchanged
Normalizeurl2025.normalize("not-a-url")
# => "not-a-url"

# Nil and empty strings return nil
Normalizeurl2025.normalize(nil)
# => nil
```

## Default Behaviour

### Tracking Parameters Removed

NormalizeURL 2025 removes these common tracking parameters by default:

**UTM Parameters:**
- `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`
- `utm_name`, `utm_cid`, `utm_reader`, `utm_viz_id`, `utm_pubreferrer`, `utm_swu`

**Click IDs:**
- `gclid` (Google Ads), `fbclid` (Facebook), `msclkid` (Microsoft Advertising)
- `yclid` (Yandex), `rb_clickid` (Rakuten)

**Analytics & Tracking:**
- `_ga`, `_gl` (Google Analytics)
- `mc_cid`, `mc_eid` (Mailchimp)
- `s_cid` (Adobe Analytics)
- `_openstat` (OpenStat)
- `ck_subscriber_id` (Kit / ConvertKit)

**Session & User IDs:**
- `PHPSESSID`, `JSESSIONID`, `ASPSESSIONID`
- `sid`, `sessionid`, `session_id`
- `subscriber_id`, `ig_rid` (Instagram)
- `oly_anon_id`, `oly_enc_id` (Optimizely)
- `wickedid`, `vero_conv`, `vero_id`

**Referrer & Source Tracking:**
- `ref`, `referer`, `referrer`, `source`, `src`
- `campaign`, `__s`

### Parameters Preserved by Domain

Certain parameters are automatically preserved for specific domains:

- **YouTube** (`youtube.com`, `youtu.be`): `v` (video ID), `t` (timestamp), `list` (playlist), `index`
- **Amazon** (`amazon.com`, `amazon.co.uk`): `keywords`, `tag`
- **eBay** (`ebay.com`, `ebay.co.uk`): `hash`
- **Google** (`google.com`, `google.co.uk`): `q` (search query)
- **Bing** (`bing.com`): `q` (search query)
- **DuckDuckGo** (`duckduckgo.com`): `q` (search query)
- **Stack Overflow** (`stackoverflow.com`): `answertab`
- **Vimeo** (`vimeo.com`): `h_original`

### URL Transformations

1. **Scheme**: Converted to lowercase (`HTTP` → `http`)
2. **Hostname**: Converted to lowercase (`Example.COM` → `example.com`)
3. **WWW prefix**: Optionally removed (`www.example.com` → `example.com`)
4. **Path**: 
   - Trailing slashes removed (except root path)
   - Empty paths become `/`
5. **Query parameters**: 
   - Tracking parameters filtered out
   - Remaining parameters sorted alphabetically
   - Empty query strings removed entirely
6. **Fragments**: Removed by default (`#section` removed)

## Advanced Usage

### Batch Processing

```ruby
urls = [
  "https://example.com/page1?utm_source=email",
  "https://example.com/page2?gclid=abc123",
  "https://example.com/page3?fbclid=def456"
]

normalized_urls = urls.map { |url| Normalizeurl2025.normalize(url) }
# => ["https://example.com/page1", "https://example.com/page2", "https://example.com/page3"]
```

### Creating Consistent Cache Keys

```ruby
def cache_key_for_url(url)
  normalized = Normalizeurl2025.normalize(url)
  Digest::MD5.hexdigest(normalized)
end

cache_key_for_url("https://example.com/article?utm_source=twitter&id=123")
# => "a1b2c3d4e5f6..." (consistent hash regardless of tracking params)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/peterc/normalizeurl2025.

## Licence

The gem is available as open source under the terms of the [MIT Licence](https://opensource.org/licenses/MIT).
