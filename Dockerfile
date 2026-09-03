## Global build args
ARG java_version="21"
ARG android_build_tools=37.0.0
ARG android_home=/opt/android/sdk
ARG java_home=/usr/lib/jvm/java-${java_version}-openjdk-amd64

# =========================================================
# Stage 1: builder — baixa e instala o Android SDK
# =========================================================
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

ARG java_home
ARG java_version
ARG android_home
ARG android_build_tools
ARG android_api=android-37.2
ARG sdk_tools_version=16111833

ENV JAVA_HOME=${java_home}
ENV ANDROID_HOME=${android_home}
ENV ANDROID_SDK_ROOT=${android_home}
ENV PATH=${PATH}:${JAVA_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin

## Ferramentas necessárias para baixar/instalar o SDK
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    ca-certificates \
    openjdk-${java_version}-jdk-headless \
    wget \
    unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

## Baixa o Android Command Line Tools
RUN mkdir -p ${android_home}/cmdline-tools \
  && wget --quiet --output-document=/tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${sdk_tools_version}_latest.zip \
  && unzip -q /tmp/cmdline-tools.zip -d /tmp \
  && mv /tmp/cmdline-tools ${android_home}/cmdline-tools/latest \
  && rm -f /tmp/cmdline-tools.zip

## Instala os componentes do SDK
RUN mkdir -p /root/.android \
  && echo '### User Sources for Android SDK Manager' > /root/.android/repositories.cfg \
  && android --no-metrics \
    --sdk=${ANDROID_HOME} sdk install \
    build-tools/${android_build_tools} \
    platforms/${android_api}

# =========================================================
# Stage 2: imagem final
# =========================================================
FROM ubuntu:24.04

LABEL maintainer="Diogo Oliveira <diogo0liveira@hotmail.com>" \
      org.opencontainers.image.title="Android SDK 37 Docker — Slim" \
      org.opencontainers.image.description="Imagem Docker mínima para compilação e análise estática do Android 37" \
      org.opencontainers.image.source="https://github.com/diogo0liveira/docker-android-37-slim" \
      dev.sigstore.cosign.signed="true"

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV TZ=Etc/UTC

## Set timezone
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

ARG java_home
ARG java_version
ARG android_home
ARG android_build_tools

ENV JAVA_HOME=${java_home}
ENV ANDROID_HOME=${android_home}
ENV ANDROID_SDK_ROOT=${android_home}
ENV PATH=${PATH}:${JAVA_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/build-tools/${android_build_tools}

## Apenas o runtime necessário para compilar
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    ca-certificates \
    openjdk-${java_version}-jdk-headless \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd -r android \
  && useradd -r -g android -d /home/android -m android

## Copia apenas os artefatos já prontos do estágio de build
COPY --from=builder --chown=android:android ${android_home} ${android_home}
COPY --from=builder --chown=android:android /root/.android /home/android/.android

USER android
WORKDIR /home/android

CMD ["/bin/bash"]
