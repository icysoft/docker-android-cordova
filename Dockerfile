FROM openjdk:8-jdk-slim

############## NODE JS ###############
ENV NODE_VERSION=10.17.0 \
    PATH=$PATH:/opt/node/bin

RUN apt-get update && apt-get install -y curl git ca-certificates --no-install-recommends && \
    curl -sL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz | tar xz --strip-components=1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

############# CORDOVA ################
ENV CORDOVA_VERSION=8.1.2
RUN npm i -g --unsafe-perm cordova@${CORDOVA_VERSION}

############# ANDROID ################
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    ANDROID_BUILD_TOOLS_VERSION=27.0.0 \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android"

ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin/:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

WORKDIR /opt

RUN dpkg --add-architecture i386 && \
    mkdir -p /usr/share/man/man1 && \
    # APTs
    apt-get -qq update && \
    apt-get -qq install -y wget libncurses5:i386 libstdc++6:i386 zlib1g:i386 && \
    apt-get -qq install -y curl maven ant gradle && \
    # Download and install
    mkdir android && cd android && \
    wget -O sdk-tools.zip ${ANDROID_SDK_URL} && \
    unzip sdk-tools.zip && rm sdk-tools.zip && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME && \
    # Clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean

RUN java -version
RUN yes | sdkmanager --licenses && yes | sdkmanager --update

    # Update SDK manager and install system image, platform and build tools
RUN sdkmanager \
  "tools" \
  "platform-tools" \
  "emulator"

RUN sdkmanager \
  "build-tools;25.0.3" \
  "build-tools;26.0.2" \
  "build-tools;27.0.3" \
  "build-tools;28.0.3"

RUN sdkmanager "platforms;android-26"