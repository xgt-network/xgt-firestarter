#!/bin/bash

XGT_CURRENCY_SYMBOL=TESTS \
XGT_NAME=initminer \
XGT_WIFS=initminer:5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n \
HOST="http://test-superproducers-lb-1733239358.us-east-1.elb.amazonaws.com:8751" \
XGT_ADDRESS_PREFIX=XGT \
CHAIN_ID=4e08b752aff5f66e1339cb8c0a8bca14c4ebb238655875db7dade86349091197 \
WIF=5JNHfZYKGaomSFvd4NUdQ9qMcEAC43kujbfjueTHpVapX1Kzq2n \
ruby main.rb

