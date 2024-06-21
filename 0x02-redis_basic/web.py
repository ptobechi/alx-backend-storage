#!/usr/bin/env python3

"""
Web caching module to fetch and cache web pages.
"""

import requests
import redis
from typing import Callable
from functools import wraps

# Create a Redis client instance
redis_client = redis.Redis()


def count_access(method: Callable) -> Callable:
    """
    Decorator to count how many times a particular URL was accessed.
    """
    @wraps(method)
    def wrapper(url: str, *args, **kwargs):
        # Increment the count for the URL
        count_key = f"count:{url}"
        redis_client.incr(count_key)
        return method(url, *args, **kwargs)
    return wrapper

def cache_page(method: Callable) -> Callable:
    """
    Decorator to cache the result of a URL request with an expiration time
    of 10 seconds.
    """
    @wraps(method)
    def wrapper(url: str, *args, **kwargs):
        # Check if the result is already cached
        cache_key = f"cache:{url}"
        cached_page = redis_client.get(cache_key)
        if cached_page:
            return cached_page.decode('utf-8')

        # If not cached, fetch the page and cache the result
        page_content = method(url, *args, **kwargs)
        redis_client.setex(cache_key, 10, page_content)
        return page_content
    return wrapper

@count_access
@cache_page
def get_page(url: str) -> str:
    """
    Fetch the HTML content of a given URL and return it.

    :param url: The URL to fetch.
    :return: The HTML content of the URL.
    """
    response = requests.get(url)
    return response.text
