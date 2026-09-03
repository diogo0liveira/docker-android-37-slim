# Android SDK 37 Docker — Slim

[![CodeQL](https://github.com/diogo0liveira/docker-android-37-slim/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/diogo0liveira/docker-android-37-slim/actions/workflows/github-code-scanning/codeql)
[![release](https://img.shields.io/github/actions/workflow/status/diogo0liveira/docker-android-37-slim/main.yml?branch=main&label=release)](https://github.com/diogo0liveira/docker-android-37-slim/actions/workflows/main.yml)
[![Provenance: SLSA 1.0](https://img.shields.io/badge/provenance-SLSA%20L1-green?logo=googlecloud)](https://github.com/diogo0liveira/docker-android-37-slim/actions/workflows/main.yml)
[![Signed by Cosign](https://img.shields.io/badge/signed%20by-cosign-blue?logo=sigstore)](https://github.com/diogo0liveira/docker-android-37-slim/actions/workflows/main.yml)
[![Latest Version](https://img.shields.io/github/v/release/diogo0liveira/docker-android-37-slim?label=version)](https://github.com/diogo0liveira/docker-android-37-slim/releases)
[![Docker Image Size](https://img.shields.io/docker/image-size/diogo0liveira/android-37-slim?label=size(amd64))](https://hub.docker.com/r/diogo0liveira/android-37-slim/1.0.0) <!-- x-release-please-version -->

Imagem Docker mínima exclusivamente para **compilação e análise estática** no (Android 17 / Baklava).

---

## 🐳 Especificações

- **Base OS**: `ubuntu:24.04` (LTS)
- **JDK**: OpenJDK `21` (headless)
- **Command-line Tools**: `16111833`
- **Android Platform**: `android-37.0.0`
- **Android Build-Tools**: `37.0.0`

---

## ⚙️ Requisitos do Projeto

- **Gradle**: `> 9.3` (mínimo `9.3.1`)
- **Android Gradle Plugin (AGP)**: `9.1+`

No arquivo `build.gradle.kts` do seu módulo `:app`:

```kotlin
android {
    buildToolsVersion = "37.0.0"

    /*
     * Seguir o formato fracionado publicado pela Google a partir da API 36
     * (ex: android-36.1, android-37.0) — projetos  que consumirem esta imagem 
     * devem usar Gradle >= 9.3.1 / AGP 9.x e declarar o
     * compileSdk com a DSL estruturada, ex:
     */
    compileSdk {
        version = release(37) {
            minorApiLevel = 2
        }
    }

    defaultConfig {
        minSdk = 24
        targetSdk = 37
    }
}
```

---

## 🚀 Como Usar

### Executar Compilação (`assemble` / `bundle` / `lint` / `test`)
<!-- x-release-please-start-version -->
```bash
docker run --rm \
  -v "$(pwd):/app" \
  -w /app \
  diogo0liveira/android-37-slim:1.0.0 \
  ./gradlew assembleRelease --no-daemon
```
<!-- x-release-please-end -->
### Usando Podman
<!-- x-release-please-start-version -->
```bash
podman run --rm \
  -v "$(pwd):/app:z" \
  -w /app \
  diogo0liveira/android-37-slim:1.0.0 \
  ./gradlew test --no-daemon
```
<!-- x-release-please-end -->
---

## 🛠️ Build Local da Imagem
<!-- x-release-please-start-version -->
```bash
docker build -t diogo0liveira/android-37-slim:1.0.0 docker-android-37-slim
```
<!-- x-release-please-end -->

---

## 🔒 Segurança e Verificação

Para garantir a integridade e procedência desta imagem, todas as versões oficiais são assinadas digitalmente usando o **Cosign** (Sigstore).

### Como verificar a assinatura
Você pode validar a imagem oficial (`ghcr.io` ou `docker.io`) executando o seguinte comando:

<!-- x-release-please-start-version -->
```bash
cosign verify ghcr.io/diogo0liveira/android-37-slim:1.0.0 \
  --certificate-identity-regexp https://github.com/diogo0liveira/docker-android-37-slim \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```
<!-- x-release-please-end -->
> [!TIP]
> A verificação garante que a imagem que você baixou foi exatamente a que foi gerada pelo GitHub Actions no repositório oficial, sem alterações de terceiros.
