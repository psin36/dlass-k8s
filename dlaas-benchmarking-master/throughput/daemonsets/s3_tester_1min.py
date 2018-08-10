#!/usr/bin/env python
from argparse import ArgumentParser
from urlparse import urlparse
from email.utils import formatdate, parsedate
from hmac import new as hmac
from hashlib import sha1
from base64 import b64encode
from httplib import HTTPConnection, HTTPSConnection
from time import time, sleep, mktime, localtime, timezone, altzone
from multiprocessing import Process, Manager


MEGABYTE = 1 << 20
CHUNK_SIZE = MEGABYTE
OBJECT_SIZE = 200 * MEGABYTE
OTHER_MACHINES_WAIT_TIME = 10
FIRST_GET_WAIT_TIME = 10
CONNECTION_COUNT = 128
TEST_TIME = 60


class BadStatus(Exception):
    pass


class S3Client(object):
    def __init__(self, object_url, access_key, secret_key):
        parsed_url = urlparse(object_url)
        self._cls = HTTPConnection if parsed_url.scheme == "http" \
            else HTTPSConnection
        self._host = parsed_url.hostname
        self._port = parsed_url.port
        self._path = parsed_url.path
        self._access_key = access_key
        self._secret_key = secret_key

    def _get_auth_headers(self, method):
        buff = method.upper() + "\n"  # method
        buff += "\n"  # content-md5
        buff += "\n"  # content-type
        date = formatdate()
        buff += date + "\n"
        buff += self._path

        sign = hmac(self._secret_key.encode("utf8"),
                    buff.encode("utf8"), sha1).digest()

        return {"Date": date,
                "Authorization": "AWS %s:%s" % (
                    self._access_key, b64encode(sign))}

    def _request(self, method, headers=None, data=None, stop_time=2e2000):
        conn = self._cls(self._host, self._port)
        conn.putrequest(method, self._path)
        headers = (headers or {}).items()
        headers += self._get_auth_headers(method).items()
        for x, y in headers:
            conn.putheader(x, y)
        conn.endheaders()
        if data:
            conn.send(data)
        resp = conn.getresponse()
        if resp.status / 100 != 2:
            raise BadStatus("Got status: %d", resp.status)
        total_bytes = 0
        while time() < stop_time:
            byte_count = len(resp.read(CHUNK_SIZE))
            if not byte_count:
                break
            total_bytes += byte_count
        resp.close()
        conn.close()
        return resp, total_bytes

    def get(self, stop_time=2e2000):
        return self._request(
            "GET", {"Content-Length": "0"}, stop_time=stop_time)

    def head(self):
        return self._request("HEAD", {"Content-Length": "0"})

    def delete(self):
        return self._request("DELETE", {"Content-Length": "0"})

    def put(self, size):
        return self._request("PUT", {"Content-Length": str(size)}, "0"*size)


def get_start_time(s3_client):
    resp, _ = s3_client.head()
    obj_time = mktime(parsedate(resp.getheader('Last-Modified'))) - (
        altzone if localtime().tm_isdst else timezone)
    return obj_time + OTHER_MACHINES_WAIT_TIME + FIRST_GET_WAIT_TIME


def worker(s3_client, start_time, results):
    stop_time = start_time + TEST_TIME
    total_bytes = 0

    while time() < start_time:
        sleep(0.01)

    while time() < stop_time:
        _, bytes_read = s3_client.get(stop_time)
        total_bytes += bytes_read

    results.put(total_bytes)


def test(object_url, access_key, secret_key):
    s = S3Client(object_url, access_key, secret_key)
    s.put(OBJECT_SIZE)
    sleep(OTHER_MACHINES_WAIT_TIME)

    resp, _ = s.head()
    obj_time = mktime(parsedate(resp.getheader('Last-Modified'))) - (
        altzone if localtime().tm_isdst else timezone)
    start_time = obj_time + OTHER_MACHINES_WAIT_TIME + FIRST_GET_WAIT_TIME

    manager = Manager()
    results = manager.Queue()
    procceses = []
    for i in xrange(CONNECTION_COUNT):
        procceses.append(Process(target=worker, args=(s, start_time, results)))
    for p in procceses:
        p.start()
    for p in procceses:
        p.join()

    sleep(OTHER_MACHINES_WAIT_TIME)

    try:
        s.delete()
    except BadStatus:
        pass

    total_bytes = 0
    while not results.empty():
        total_bytes += results.get()

    print "%d MB/s" % (total_bytes/(MEGABYTE*TEST_TIME))


def main():
    parser = ArgumentParser()
    parser.add_argument('object_url')
    parser.add_argument('access_key')
    parser.add_argument('secret_key')
    args = parser.parse_args()

    test(args.object_url, args.access_key, args.secret_key)


def sleep_forever():
    while 1:
        sleep(1000)

if __name__ == "__main__":
    main()
    sleep_forever()