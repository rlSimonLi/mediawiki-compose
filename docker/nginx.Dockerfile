FROM debian:12 as compile

ARG OPENSSL_VERSION=openssl-3.1.5
ARG NGINX_VERSION=master

WORKDIR /src
RUN apt-get update && apt-get install -y git build-essential wget curl libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev cmake

RUN export CFLAGS="-march=native -mtune=native -Ofast -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections"
RUN export LDFLAGS="-Wl,-s -Wl,-Bsymbolic -Wl,--gc-sections"

RUN git clone -j8 --depth 1 --recurse-submodules https://github.com/google/ngx_brotli.git ngx_brotli
RUN cd /src/ngx_brotli/deps/brotli && \
      mkdir out && cd out && \
      cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed .. && \
      cmake --build . --config Release --target brotlienc

RUN git clone -j8 --depth 1 -b ${OPENSSL_VERSION}+quic --recurse-submodules https://github.com/quictls/openssl.git quictls

RUN git clone --depth 1 -b ${NGINX_VERSION} https://github.com/nginx/nginx
RUN cd /src/nginx && \
      ./auto/configure \
      --prefix=/usr/local/nginx \
      --sbin-path=/usr/sbin/nginx \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --with-http_ssl_module \
      --with-http_v2_module \
      --with-http_v3_module \
      --with-openssl=../quictls \
      --add-module=/src/ngx_brotli \
      --with-http_stub_status_module \
      --with-threads \
      --with-file-aio && \
      make && \
      make install

FROM debian:12-slim as runtime

RUN apt-get update && apt-get upgrade -y
RUN apt-get install libpcre3 libpcre3-dev -y
RUN addgroup --system --gid 101 nginx \
      && adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx

COPY --from=compile /usr/local/nginx /usr/local/nginx
COPY --from=compile /usr/sbin/nginx /usr/sbin/nginx
COPY --from=compile /etc/nginx /etc/nginx
COPY --from=compile /var/log/nginx /var/log/nginx

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
      ln -sf /dev/stderr /var/log/nginx/error.log

RUN rm /etc/localtime && \
      ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

EXPOSE 80 443 443/udp

STOPSIGNAL SIGQUIT

CMD [ "nginx", "-g", "daemon off;"]