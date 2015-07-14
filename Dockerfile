FROM appertly/hhvm:3.8.0
MAINTAINER Jonathan Hawk <jonathan@appertly.com>

ENV HHVM_DEV_VERSION 3.8.0~jessie

# Install and build libbson and mongofill
RUN mkdir /tmp/builds \
    && buildDeps="wget git-core libtool make hhvm-dev=$HHVM_DEV_VERSION" \
    && set -x \
    && apt-get update && apt-get install -y --no-install-recommends $buildDeps \
    && rm -rf /var/lib/apt/lists/* \
    && git clone git://github.com/mongodb/libbson.git /tmp/builds/libbson \
    && git clone https://github.com/mongofill/mongofill-hhvm /tmp/builds/mongofill-hhvm \
    && cd /tmp/builds/libbson \
    && ./autogen.sh \
    && make \
    && make install \
    && cd /tmp/builds/mongofill-hhvm \
    && ./build.sh \
    && mkdir -p /usr/lib/hhvm/extensions \
    && cp /tmp/builds/mongofill-hhvm/mongo.so /usr/lib/hhvm/extensions/mongo.so \
    && cd / && rm -rf /tmp/builds \
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get autoremove -y

RUN echo "hhvm.dynamic_extension_path = /usr/lib/hhvm/extensions" >> /etc/hhvm/server.ini \
    && echo "hhvm.dynamic_extensions[mongo] = mongo.so" >> /etc/hhvm/server.ini \
    && echo "hhvm.dynamic_extension_path = /usr/lib/hhvm/extensions" >> /etc/hhvm/php.ini \
    && echo "hhvm.dynamic_extensions[mongo] = mongo.so" >> /etc/hhvm/php.ini
