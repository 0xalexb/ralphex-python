ARG RALPHEX_VERSION=latest

FROM ghcr.io/umputun/ralphex:${RALPHEX_VERSION}

ARG PHP_VERSION=8.5
ARG COMPOSER_VERSION=latest-stable
ARG PHPSTAN_VERSION=2.1.14

# install php and required extensions
RUN PHP_SHORT=$(echo ${PHP_VERSION} | tr -d '.') && \
    apk add --no-cache \
        php${PHP_SHORT} \
        php${PHP_SHORT}-phar \
        php${PHP_SHORT}-mbstring \
        php${PHP_SHORT}-openssl \
        php${PHP_SHORT}-curl \
        php${PHP_SHORT}-iconv \
        php${PHP_SHORT}-zip \
        php${PHP_SHORT}-dom \
        php${PHP_SHORT}-xml \
        php${PHP_SHORT}-xmlwriter \
        php${PHP_SHORT}-tokenizer \
        php${PHP_SHORT}-simplexml \
        bash \
        jq \
        yq && \
    ln -sf /usr/bin/php${PHP_SHORT} /usr/local/bin/php

# install composer
RUN if [ "${COMPOSER_VERSION}" = "latest-stable" ]; then \
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    else \
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION}; \
    fi

# install phpstan
RUN curl -sLo /usr/local/bin/phpstan https://github.com/phpstan/phpstan/releases/download/${PHPSTAN_VERSION}/phpstan.phar && \
    chmod +x /usr/local/bin/phpstan

# install claude code, codex, and pi
# codex ships its native binary as an aliased optional dependency
# (@openai/codex-linux-<arch>), which npm intermittently fails to install under
# QEMU-emulated multi-arch builds. The miss is silent because the dep is
# optional, so the build only fails later at `codex --version`. Install the
# arch-matched binary explicitly (as a required package) to make builds deterministic.
ARG CLAUDE_CODE_VERSION=latest
ARG CODEX_VERSION=latest
ARG PI_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} @openai/codex@${CODEX_VERSION} @earendil-works/pi-coding-agent@${PI_VERSION} && \
    ARCH=$(uname -m | sed 's/x86_64/x64/;s/aarch64/arm64/') && \
    CODEX_RESOLVED=$(node -p "require('$(npm root -g)/@openai/codex/package.json').version") && \
    npm install -g "@openai/codex-linux-${ARCH}@npm:@openai/codex@${CODEX_RESOLVED}-linux-${ARCH}"

# verify installations
RUN php --version && composer --version && phpstan --version && jq --version && yq --version && claude --version && codex --version && pi --version
