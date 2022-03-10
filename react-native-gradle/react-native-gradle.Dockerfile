FROM gradle:7.4-jdk8
WORKDIR /sdk

ENV SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip" \
    ANDROID_HOME="/sdk" \
    PATH="$PATH:${ANDROID_HOME}/cmdline-tools/bin" \
    NODE_VERSION=16.x

RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get -qq update \
    && apt-get install -qqy --no-install-recommends \
        nodejs \
        curl \
        unzip \
    && npm i -g yarn \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -s ${SDK_URL} > /tools.zip \
    && unzip /tools.zip -d ${ANDROID_HOME} \
    && rm /tools.zip

ADD packages.txt /sdk

RUN mkdir -p /root/.android \
    && touch /root/.android/repositories.cfg \
    && ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt \
    && ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} ${PACKAGES}