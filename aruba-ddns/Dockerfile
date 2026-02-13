ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG DEHYDRATED_VERSION
RUN apk add --no-cache curl jq coreutils openssl \
  && curl -fsSL -o /usr/bin/dehydrated "https://raw.githubusercontent.com/Xebozone/dehydrated/${DEHYDRATED_VERSION}/dehydrated" \
  && chmod +x /usr/bin/dehydrated

COPY rootfs /
