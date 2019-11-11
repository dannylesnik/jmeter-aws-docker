# Use a minimal base image with OpenJDK installed
FROM openjdk:8-jre-alpine3.7

# Install packages
RUN apk update && \
    apk add ca-certificates wget python python-dev py-pip && \
    update-ca-certificates && \
    apk add curl && \
    pip install --upgrade && \
    pip install --upgrade --user awscli

# Set variables
ENV JMETER_HOME=/usr/share/apache-jmeter \
    JMETER_VERSION=5.1.1 \
    TEST_SCRIPT_FILE=/var/jmeter/test.jmx \
    TEST_LOG_FILE=/var/jmeter/test.log \
    TEST_RESULTS_FILE=/var/jmeter/test-result.csv \
    #USE_CACHED_SSL_CONTEXT=false \
    NUMBER_OF_THREADS=1000 \
    RAMP_UP_TIME=25 \
    #CERTIFICATES_FILE=/var/jmeter/certificates.csv \
    #KEYSTORE_FILE=/var/jmeter/keystore.jks \
    KEYSTORE_PASSWORD=secret \
    HOST=nginx \
    PORT=80 \
    OPEN_CONNECTION_WAIT_TIME=5000 \
    OPEN_CONNECTION_TIMEOUT=20000 \
    OPEN_CONNECTION_READ_TIMEOUT=6000 \
    NUMBER_OF_MESSAGES=8 \
    DATA_TO_SEND=cafebabecafebabe \
    BEFORE_SEND_DATA_WAIT_TIME=5000 \
    SEND_DATA_WAIT_TIME=1000 \
    SEND_DATA_READ_TIMEOUT=6000 \
    CLOSE_CONNECTION_WAIT_TIME=5000 \
    CLOSE_CONNECTION_READ_TIMEOUT=6000 \
    BUCKET_NAME="" \
    PATH="~/.local/bin:$PATH" \
    JVM_ARGS="-Xms2048m -Xmx4096m -XX:NewSize=1024m -XX:MaxNewSize=2048m -Duser.timezone=UTC"


# Install Apache JMeter
RUN wget http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar zxvf apache-jmeter-${JMETER_VERSION}.tgz && \
    rm -f apache-jmeter-${JMETER_VERSION}.tgz && \
    mv apache-jmeter-${JMETER_VERSION} ${JMETER_HOME}


# Copy keystore and table
#COPY certs.jks ${KEYSTORE_FILE}
#COPY certs.csv ${CERTIFICATES_FILE}


# The main command, where several things happen:
# - Empty the log and result files
# - Start the JMeter script
# - Echo the log and result files' contents
CMD echo -n > $TEST_LOG_FILE && \
    echo -n > $TEST_RESULTS_FILE && \
    export PATH=~/.local/bin:$PATH && \
    $JMETER_HOME/bin/jmeter -n \
    -t $TEST_SCRIPT_FILE \
    -j $TEST_LOG_FILE \
    -l $TEST_RESULTS_FILE \
  #  -Djavax.net.ssl.keyStore=$KEYSTORE_FILE \
  #  -Djavax.net.ssl.keyStorePassword=$KEYSTORE_PASSWORD \
  #  -Jhttps.use.cached.ssl.context=$USE_CACHED_SSL_CONTEXT \
    -Jjmeter.save.saveservice.output_format=csv \
    -Jjmeter.save.saveservice.response_data=true \
    -Jjmeter.save.saveservice.samplerData=true \
    -JnumberOfThreads=$NUMBER_OF_THREADS \
    -JrampUpTime=$RAMP_UP_TIME \
    #-Jlog_level.jmeter=INFO \
    #-JcertFile=$CERTIFICATES_FILE \
    -Jhost=$HOST \
    -Jport=$PORT \
    -Lorg.apache.jmeter.protocol.http.control=INFO \
    -Lorg.apache.http=INFO \
    -LINFO \
    -JopenConnectionWaitTime=$OPEN_CONNECTION_WAIT_TIME \
    -JopenConnectionConnectTimeout=$OPEN_CONNECTION_TIMEOUT \
    -JopenConnectionReadTimeout=$OPEN_CONNECTION_READ_TIMEOUT \
    -JnumberOfMessages=$NUMBER_OF_MESSAGES \
    -JdataToSend=$DATA_TO_SEND \
    -JbeforeSendDataWaitTime=$BEFORE_SEND_DATA_WAIT_TIME \
    -JsendDataWaitTime=$SEND_DATA_WAIT_TIME \
    -JsendDataReadTimeout=$SEND_DATA_READ_TIMEOUT \
    -JcloseConnectionWaitTime=$CLOSE_CONNECTION_WAIT_TIME \
    -JcloseConnectionReadTimeout=$CLOSE_CONNECTION_READ_TIMEOUT && \
    aws s3 cp $TEST_LOG_FILE s3://${BUCKET_NAME}/test_logs/ && \
    aws s3 cp $TEST_RESULTS_FILE s3://${BUCKET_NAME}/test_results/${EXECUTION_ID}/ && \
    echo -e "\n\n===== TEST LOGS =====\n\n" && \
    sleep 10000h && \
    cat $TEST_LOG_FILE && \
    echo -e "\n\n===== TEST RESULTS =====\n\n" && \
    cat $TEST_RESULTS_FILE  && \
    /bin/sh  