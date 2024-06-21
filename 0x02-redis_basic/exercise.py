#!/usr/bin/env python3

"""
Cache module to interact with Redis and store call history.
"""

import redis
import uuid
from typing import Union, Callable, Optional
import functools


def count_calls(method: Callable) -> Callable:
    """
    Decorator to count calls to a method.
    """
    @functools.wraps(method)
    def wrapper(self, *args, **kwargs):
        """
        Wrapper function to increment call count in Redis and call the original method.
        """
        key = method.__qualname__
        self._redis.incr(key)
        return method(self, *args, **kwargs)
    return wrapper

def call_history(method: Callable) -> Callable:
    """
    Decorator to store the history of inputs and outputs for a function.
    """
    @functools.wraps(method)
    def wrapper(self, *args, **kwargs):
        """
        Wrapper function to store the input and output history in Redis.
        """
        input_key = f"{method.__qualname__}:inputs"
        output_key = f"{method.__qualname__}:outputs"

        # Store the input arguments
        self._redis.rpush(input_key, str(args))

        # Call the original method and store the output
        result = method(self, *args, **kwargs)
        self._redis.rpush(output_key, str(result))

        return result

    return wrapper

def replay(method: Callable) -> None:
    """
    Function to display the history of calls of a particular function.

    :param method: The method to replay the history for.
    """
    redis_instance = method.__self__._redis
    input_key = f"{method.__qualname__}:inputs"
    output_key = f"{method.__qualname__}:outputs"

    inputs = redis_instance.lrange(input_key, 0, -1)
    outputs = redis_instance.lrange(output_key, 0, -1)

    print(f"{method.__qualname__} was called {len(inputs)} times:")
    for input_, output in zip(inputs, outputs):
        print(f"{method.__qualname__}(*{input_.decode('utf-8')}) -> {output.decode('utf-8')}")

class Cache:
    """
    Cache class for storing data in Redis, counting method calls, and storing call history.
    """

    def __init__(self) -> None:
        """
        Initialize the Cache instance with a Redis client and flush the database.
        """
        self._redis = redis.Redis()
        self._redis.flushdb()

    @count_calls
    @call_history
    def store(self, data: Union[str, bytes, int, float]) -> str:
        """
        Store the data in Redis with a randomly generated key.

        :param data: The data to store in Redis. Can be of type str, bytes, int, or float.
        :return: The key under which the data is stored.
        """
        key = str(uuid.uuid4())
        self._redis.set(key, data)
        return key

    def get(self, key: str, fn: Optional[Callable[[bytes], Union[str, bytes, int, float]]] = None) -> Optional[Union[str, bytes, int, float]]:
        """
        Retrieve data from Redis by key and optionally apply a conversion function.

        :param key: The key to retrieve from Redis.
        :param fn: An optional callable to convert the data.
        :return: The retrieved data, possibly converted, or None if key does not exist.
        """
        data = self._redis.get(key)
        if data is None:
            return None
        if fn:
            return fn(data)
        return data

    def get_str(self, key: str) -> Optional[str]:
        """
        Retrieve data from Redis by key and convert it to a string.

        :param key: The key to retrieve from Redis.
        :return: The retrieved data as a string, or None if key does not exist.
        """
        return self.get(key, lambda d: d.decode("utf-8"))

    def get_int(self, key: str) -> Optional[int]:
        """
        Retrieve data from Redis by key and convert it to an integer.

        :param key: The key to retrieve from Redis.
        :return: The retrieved data as an integer, or None if key does not exist.
        """
        return self.get(key, lambda d: int(d))

# Example usage and test cases
if __name__ == "__main__":
    cache = Cache()

    # Store data and check call history
    s1 = cache.store("foo")
    print(s1)
    s2 = cache.store("bar")
    print(s2)
    s3 = cache.store(42)
    print(s3)

    replay(cache.store)
