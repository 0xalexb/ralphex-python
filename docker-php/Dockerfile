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
        jq && \
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

# install claude code and codex
ARG CLAUDE_CODE_VERSION=latest
ARG CODEX_VERSION=latest
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} @openai/codex@${CODEX_VERSION}

# verify installations
RUN php --version && composer --version && phpstan --version && jq --version && claude --version && codex --version
