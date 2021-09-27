#!/bin/sh

exec nmap -sV $1 -p - -T4 \
    --script ssl-enum-ciphers \
    --script ssl-heartbleed \
    --script ssl-poodle \
    --script ssl-known-key \
    --script http-csrf \
    --script http-headers \
    --script http-sql-injection \
    --script http-stored-xss \
    --script http-dombased-xss \
    --script-args useget,http.useragent="'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36'" $*
