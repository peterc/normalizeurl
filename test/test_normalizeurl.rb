# frozen_string_literal: true

require "test_helper"

class TestNormalizeurl < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Normalizeurl::VERSION
  end

  def test_normalize_basic_url
    url = "https://EXAMPLE.COM/Path/"
    expected = "https://example.com/Path"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_removes_utm_params
    url = "https://example.com/page?utm_source=google&utm_medium=cpc&important=keep"
    expected = "https://example.com/page?important=keep"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_preserves_youtube_params
    url = "https://youtube.com/watch?v=dQw4w9WgXcQ&utm_source=twitter&t=42"
    expected = "https://youtube.com/watch?t=42&v=dQw4w9WgXcQ"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_removes_session_ids
    url = "https://example.com/page?PHPSESSID=abc123&content=important"
    expected = "https://example.com/page?content=important"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_removes_tracking_pixels
    url = "https://example.com/page?_ga=GA1.2.123456&fbclid=IwAR123&content=keep"
    expected = "https://example.com/page?content=keep"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_handles_empty_query_after_filtering
    url = "https://example.com/page?utm_source=google&utm_medium=cpc"
    expected = "https://example.com/page"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_sorts_remaining_params
    url = "https://example.com/page?zebra=last&alpha=first&beta=middle"
    expected = "https://example.com/page?alpha=first&beta=middle&zebra=last"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_removes_fragment_by_default
    url = "https://example.com/page#section"
    expected = "https://example.com/page"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_with_custom_options
    url = "https://WWW.EXAMPLE.COM/page/?utm_source=test#fragment"
    options = {
      remove_www: true,
      remove_fragment: false,
      remove_trailing_slash: false
    }
    expected = "https://example.com/page/#fragment"
    assert_equal expected, Normalizeurl.normalize(url, options)
  end

  def test_normalize_handles_nil_and_empty_urls
    assert_nil Normalizeurl.normalize(nil)
    assert_nil Normalizeurl.normalize("")
    assert_nil Normalizeurl.normalize("   ")
  end

  def test_normalize_handles_invalid_urls
    invalid_url = "not-a-url"
    assert_equal invalid_url, Normalizeurl.normalize(invalid_url)
  end

  def test_normalize_only_processes_http_urls
    ftp_url = "ftp://example.com/file.txt"
    assert_equal ftp_url, Normalizeurl.normalize(ftp_url)
  end

  def test_normalize_preserves_important_amazon_params
    url = "https://amazon.com/product?tag=affiliate&utm_source=google&keywords=search"
    expected = "https://amazon.com/product?keywords=search&tag=affiliate"
    assert_equal expected, Normalizeurl.normalize(url)
  end

  def test_normalize_with_custom_tracking_params
    url = "https://example.com/page?custom_tracker=123&normal_param=keep"
    options = { custom_tracking_params: ['custom_tracker'] }
    expected = "https://example.com/page?normal_param=keep"
    assert_equal expected, Normalizeurl.normalize(url, options)
  end

  def test_normalize_with_custom_preserve_params
    url = "https://example.com/page?special_param=keep&utm_source=remove"
    options = { preserve_params: { 'example.com' => ['special_param'] } }
    expected = "https://example.com/page?special_param=keep"
    assert_equal expected, Normalizeurl.normalize(url, options)
  end
end
