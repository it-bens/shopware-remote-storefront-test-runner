## build context is at docker/

ARG SHOPWARE_VERSION=""
ARG LOCALE=""
ARG CURRENCY=""

FROM ghcr.io/it-bens/it-bens/shopware-remote-api-test-runner:${SHOPWARE_VERSION}_${LOCALE}_${CURRENCY}

ARG STOREFRONT_DOMAIN="localhost"

LABEL org.opencontainers.image.authors="Martin Bens <martin.bens@it-bens.de>" \
      org.opencontainers.image.title="Shopware Remote Storefront Test Wrapper" \
      org.opencontainers.image.source="https://github.com/it-bens/shopware-remote-storefront-test-runner" \
      org.opencontainers.image.description="A Docker image for running Shopware with a remote storefront for testing purposes." \
      org.opencontainers.image.licenses="MIT" \
      shopware.storefront_domain=$STOREFRONT_DOMAIN

# install Node.js
RUN set -ex; \
    curl -fsSL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh && \
    chmod +x /tmp/nodesource_setup.sh && \
    /tmp/nodesource_setup.sh && \
    apt-get update && \
    apt-get -y --no-install-recommends install nodejs && \
    node -v && \
    npm -v

# install yq for YAML minupulation. Update Shopware filesystem configuration. Delete yq. Rebuild Shopware/Symfony cache
RUN set -ex; \
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    yq -i '.shopware.filesystem.public.type = "local"' /opt/shopware-remote-api-test-runner/vendor/shopware/platform/src/Core/Framework/Resources/config/packages/test/shopware.yaml && \
    yq -i '.shopware.filesystem.public.config.root = "/opt/shopware-remote-api-test-runner/public"' /opt/shopware-remote-api-test-runner/vendor/shopware/platform/src/Core/Framework/Resources/config/packages/test/shopware.yaml && \
    rm /usr/bin/yq

# install storefront JS and assets and change Storefront theme
ADD ./code/bin/build-storefront.sh /opt/shopware-remote-api-test-runner/bin/
RUN set -ex; \
    service mariadb start && \
    cd /opt/shopware-remote-api-test-runner && \
    chmod +x bin/build-storefront.sh && \
    sudo -u www-data php -d memory_limit=-1 bin/console cache:clear && \
    bin/build-storefront.sh && \
    chown -R www-data:www-data /opt/shopware-remote-api-test-runner && \
    sudo -u www-data php -d memory_limit=-1 bin/console theme:change Storefront --all && \
    service mariadb restart
RUN set -ex; \
    service mariadb start && \
    sudo -u www-data php -d memory_limit=-1 /opt/shopware-remote-api-test-runner/bin/console sales-channel:update:domain "${STOREFRONT_DOMAIN}" && \
    service mariadb restart

# copy modified index.php to allow storefton access and forbid API access
ADD ./code/public/index.php /opt/shopware-remote-api-test-runner/public/
