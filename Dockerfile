FROM postgres:14

ARG POSTGRES_BASE_VERSION=14
ARG ARROW_TAG=apache-arrow-10.0.0
ARG AWS_SDK_TAG=1.10.4

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install gnupg postgresql-common git -y
RUN sh /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y \
      postgresql-${POSTGRES_BASE_VERSION} \
      postgresql-server-dev-${POSTGRES_BASE_VERSION} \
      build-essential \
      cmake \
      ninja-build \
      lsb-release \
      wget \
      # aws sdk deps
      libcurl4-openssl-dev \
      libssl-dev \
      uuid-dev \
      zlib1g-dev \
      libpulse-dev

RUN set -eux; \
    apt update ;\
    wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb ;\
    apt install -y -V ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb ;\
    apt update ;\
    apt install -y -V libarrow-dev libparquet-dev

RUN set -eux; \
    git clone https://github.com/aws/aws-sdk-cpp --recurse-submodules --branch ${AWS_SDK_TAG} --single-branch ;\
    mkdir sdk_build ;\
    cd sdk_build ;\
    cmake ../aws-sdk-cpp -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local/ -DCMAKE_INSTALL_PREFIX=/usr/local/ -DBUILD_ONLY="s3" ;\
    nproc | xargs -I % make -j% ;\
    nproc | xargs -I % make -j% install

# make sure the right postgres version is active
ENV PATH="/usr/lib/postgresql/${POSTGRES_BASE_VERSION}/bin:$PATH"

COPY . .

RUN set -eux; \
  DESTDIR=/ make USE_PGXS=1; \
  DESTDIR=/ make USE_PGXS=1 install
