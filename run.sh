#!/bin/bash

echo "Starting Jmeter execution"
echo "Updating ENV Variables"

JMETER_HOME=/Users/dannylesnik/Downloads/apache-jmeter-5.1.1
TEST_SCRIPT_FILE=/Users/dannylesnik/Documents/Images/jmeter/my_script.jmx
TEST_LOG_FILE=test.log
TEST_RESULTS_FILE=/Users/dannylesnik/Documents/Images/jmeter/test-result.xml
NUMBER_OF_THREADS=1000 
RAMP_UP_TIME=25 
KEYSTORE_PASSWORD=secret
HOST=nginx
PORT=80
OPEN_CONNECTION_WAIT_TIME=5000
OPEN_CONNECTION_TIMEOUT=20000
OPEN_CONNECTION_READ_TIMEOUT=6000
NUMBER_OF_MESSAGES=8
DATA_TO_SEND=cafebabecafebabe
BEFORE_SEND_DATA_WAIT_TIME=5000
SEND_DATA_WAIT_TIME=1000
SEND_DATA_READ_TIMEOUT=6000
CLOSE_CONNECTION_WAIT_TIME=5000
CLOSE_CONNECTION_READ_TIMEOUT=6000



$JMETER_HOME/bin/jmeter -n \
    -t $TEST_SCRIPT_FILE \
    -j $TEST_LOG_FILE \
    -l $TEST_RESULTS_FILE \
    -Jjmeter.save.saveservice.output_format=xml \
    -Jjmeter.save.saveservice.response_data=true \
    -Jjmeter.save.saveservice.samplerData=true \
    -JnumberOfThreads=$NUMBER_OF_THREADS \
    -JrampUpTime=$RAMP_UP_TIME \
    -Jhost=$HOST \
    -Jport=$PORT \
    -JopenConnectionWaitTime=$OPEN_CONNECTION_WAIT_TIME \
    -JopenConnectionConnectTimeout=$OPEN_CONNECTION_TIMEOUT \
    -JopenConnectionReadTimeout=$OPEN_CONNECTION_READ_TIMEOUT \
    -JnumberOfMessages=$NUMBER_OF_MESSAGES \
    -JdataToSend=$DATA_TO_SEND \
    -JbeforeSendDataWaitTime=$BEFORE_SEND_DATA_WAIT_TIME \
    -JsendDataWaitTime=$SEND_DATA_WAIT_TIME \
    -JsendDataReadTimeout=$SEND_DATA_READ_TIMEOUT \
    -JcloseConnectionWaitTime=$CLOSE_CONNECTION_WAIT_TIME \
    -JcloseConnectionReadTimeout=$CLOSE_CONNECTION_READ_TIMEOUT