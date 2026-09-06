# syntax=docker/dockerfile:1
ARG JAVA_VERSION="21"
ARG JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64

ARG ANDROID_API=android-37.2
ARG ANDROID_BUILD_TOOLS=37.0.0
ARG ANDROID_HOME=/opt/android/sdk

# =========================================================
# Stage 1: builder — baixa e instala o Android SDK
# =========================================================
FROM ubuntu:24.04 AS builder

ARG JAVA_HOME
ARG JAVA_VERSION
ARG ANDROID_HOME
ARG ANDROID_API
ARG ANDROID_BUILD_TOOLS
ARG SDK_TOOLS_VERSION=16111833

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=${JAVA_HOME}
ENV ANDROID_HOME=${ANDROID_HOME}
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV PATH=${PATH}:${JAVA_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin

## Ferramentas para baixar/instalar o SDK
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    ca-certificates \
    openjdk-${JAVA_VERSION}-jdk-headless \
    wget \
    unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

## Baixa o Android Command Line Tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
  && wget --quiet --output-document=/tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS_VERSION}_latest.zip \
  && unzip -q /tmp/cmdline-tools.zip -d /tmp \
  && mv /tmp/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
  && rm -f /tmp/cmdline-tools.zip

## Instala os componentes do SDK
RUN mkdir -p /root/.android \
  && echo '### User Sources for Android SDK Manager' > /root/.android/repositories.cfg \
  && android --no-metrics \
    --sdk=${ANDROID_HOME} sdk install \
    build-tools/${ANDROID_BUILD_TOOLS} \
    platforms/${ANDROID_API}

# =========================================================
# Stage 2: imagem final
# =========================================================
FROM ubuntu:24.04
ARG JAVA_HOME
ARG JAVA_VERSION
ARG ANDROID_HOME
ARG ANDROID_API
ARG ANDROID_BUILD_TOOLS

LABEL maintainer="Diogo Oliveira <diogo0liveira@hotmail.com>" \
      org.opencontainers.image.title="Android SDK 37 Docker — Slim" \
      org.opencontainers.image.description="Imagem Docker mínima para compilação e análise estática do Android 37" \
      org.opencontainers.image.source="https://github.com/diogo0liveira/docker-android-37-slim" \
      dev.sigstore.cosign.signed="true" \
      dev.diogo0liveira.java.version="${JAVA_VERSION}" \
      dev.diogo0liveira.android.api.version="${ANDROID_API}" \
      dev.diogo0liveira.android.build.tools.version="${ANDROID_BUILD_TOOLS}"

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV TZ=Etc/UTC

## Set timezone
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

ENV JAVA_HOME=${JAVA_HOME}
ENV ANDROID_HOME=${ANDROID_HOME}
ENV ANDROID_SDK_ROOT=${ANDROID_HOME}
ENV PATH=${PATH}:${JAVA_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS}

## Apenas o runtime necessário para compilar
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    ca-certificates \
    openjdk-${JAVA_VERSION}-jdk-headless \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd -r android \
  && useradd -r -g android -d /home/android -m android

## Copia apenas os artefatos já prontos do estágio de build
COPY --from=builder --chown=android:android ${ANDROID_HOME} ${ANDROID_HOME}
COPY --from=builder --chown=android:android /root/.android /home/android/.android

USER android
WORKDIR /home/android

CMD ["/bin/bash"]
