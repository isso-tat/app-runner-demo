#!/bin/bash

siege\
	--concurrent=10 \
	--time=60s \
	--benchmark \
	--file=./URLS.txt