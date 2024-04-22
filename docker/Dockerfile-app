FROM php:8.3.6-fpm-bookworm as mediawiki-git

ARG MEDIAWIKI_VERSION=REL1_41

# Update packages
RUN apt-get update && \
    apt-get upgrade -y

RUN apt-get install git wget -y

WORKDIR /src

RUN git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki.git /src/mediawiki
RUN cd /src/mediawiki && \
    rm -rf ./.git && \
    rm -rf extensions && \
    rm -rf skins && \
    rm -rf vendor

# Bbundled extensions as of 1.41: https://www.mediawiki.org/wiki/Bundled_extensions_and_skins
RUN cd /src/mediawiki && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-AbuseFilter.git extensions/AbuseFilter && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-CategoryTree.git extensions/CategoryTree && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-Cite.git extensions/Cite && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-CiteThisPage.git extensions/CiteThisPage && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-CodeEditor.git extensions/CodeEditor && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-ConfirmEdit.git extensions/ConfirmEdit && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-Gadgets.git extensions/Gadgets && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-ImageMap.git extensions/ImageMap && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-InputBox.git extensions/InputBox && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-Interwiki.git extensions/Interwiki && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-Math.git extensions/Math && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-MultimediaViewer.git extensions/MultimediaViewer && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-Nuke.git extensions/Nuke && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-OATHAuth.git extensions/OATHAuth && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-PageImages.git extensions/PageImages && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-ParserFunctions.git extensions/ParserFunctions && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-PdfHandler.git extensions/PdfHandler && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-Poem.git extensions/Poem && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-ReplaceText.git extensions/ReplaceText && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-Scribunto.git extensions/Scribunto && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-SecureLinkFixer.git extensions/SecureLinkFixer && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-SpamBlacklist.git extensions/SpamBlacklist && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-SyntaxHighlight_GeSHi.git extensions/SyntaxHighlight_GeSHi && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-TemplateData.git extensions/TemplateData && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-TextExtracts.git extensions/TextExtracts && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-TitleBlacklist.git extensions/TitleBlacklist && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 -j8 --recurse-submodules https://github.com/wikimedia/mediawiki-extensions-VisualEditor.git extensions/VisualEditor && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-extensions-WikiEditor.git extensions/WikiEditor && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-skins-MinervaNeue.git skins/MinervaNeue && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-skins-MonoBook.git skins/MonoBook && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-skins-Timeless.git skins/Timeless && \
    git clone -b ${MEDIAWIKI_VERSION} --depth=1 https://github.com/wikimedia/mediawiki-skins-Vector.git skins/Vector


RUN cd /src/mediawiki && \
    git clone -b master --depth=1 https://github.com/edwardspec/mediawiki-aws-s3.git extensions/AWS


RUN cd /src/mediawiki && \
    git init && \
    git add -A && \
    git config --global user.name "" && \
    git config --global user.email "" && \
    git commit -m "Build latest mediawiki"


FROM php:8.3.6-fpm-bookworm as runtime

ARG IMAGICK_VERSION=3.7.0
ARG LUASANDBOX_VERSION=4.1.2
ARG REDIS_VERSION=6.0.2


RUN chown -R www-data:www-data /var/www/html

# Update packages
RUN apt-get update && \
    apt-get upgrade -y

# Git
RUN apt-get install git librsvg2-dev libheif-dev unzip -y


# Imagick
RUN apt-get install imagemagick libmagickwand-dev -y && \
    pecl install imagick-${IMAGICK_VERSION} && \
    docker-php-ext-enable imagick

# Lua and LuaSandbox
RUN apt-get install liblua5.1-0-dev -y && \
    pecl install luasandbox-${LUASANDBOX_VERSION} && \
    docker-php-ext-enable luasandbox

# ffmpeg
RUN apt-get install ffmpeg libmp3lame-dev -y

# MySQL
RUN docker-php-ext-install mysqli

# opcache
RUN docker-php-ext-install opcache

# International Components for Unicode
RUN docker-php-ext-install intl

# redis
RUN pecl install redis-${REDIS_VERSION} && \
    docker-php-ext-enable redis

# Multi processing
RUN docker-php-ext-install pcntl


COPY --chown=www-data:www-data --from=mediawiki-git /src/mediawiki /var/www/html

# Install Composer
RUN curl https://getcomposer.org/composer-2.phar > /usr/local/bin/composer && chmod +x /usr/local/bin/composer
RUN docker-php-ext-install calendar

# Install vendor libraries
USER www-data
RUN mv /var/www/html/composer.local.json-sample /var/www/html/composer.local.json
RUN cd /var/www/html && \
    composer update --no-dev --no-cache


RUN ln -s /mw-mount/LocalSettings.php /var/www/html/LocalSettings.php

USER root
COPY ./docker/entrypoint.sh /src/entrypoint.sh
COPY ./docker/runner.sh /src/runner.sh
RUN chmod +x /src/runner.sh

ENTRYPOINT ["/bin/sh", "/src/entrypoint.sh"]

CMD ["php-fpm"]
