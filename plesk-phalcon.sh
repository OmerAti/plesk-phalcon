#!/bin/bash
#JRodix.Com Internet Hizmetleri OmerAti

php_versions=("7.0" "7.1" "7.2" "7.3" "7.4")


yum install -y git gcc make autoconf re2c


if [ -d /usr/src/cphalcon ]; then
    rm -rf /usr/src/cphalcon
fi
git clone --branch v4.2.1 --depth 1 https://github.com/phalcon/cphalcon.git /usr/src/cphalcon


for ver in "${php_versions[@]}"; do
    php_prefix="/opt/plesk/php/${ver}"
    php_bin="${php_prefix}/bin/php"
    phpize="${php_prefix}/bin/phpize"
    php_config="${php_prefix}/bin/php-config"
    modules_dir="$(${php_bin} -r 'echo ini_get("extension_dir");')"

    if [ -x "$phpize" ] && [ -x "$php_config" ]; then
        echo ">>> PHP $ver icin Phalcon kuruluyor..."

        cd /usr/src/cphalcon/build
        export PATH="${php_prefix}/bin:$PATH"
        ./install --phpize "$phpize" --php-config "$php_config"

        cp /usr/src/cphalcon/build/64bits/phalcon.so "${modules_dir}/"

        echo "extension=phalcon.so" > "${php_prefix}/etc/php.d/phalcon.ini"

        systemctl restart "plesk-php${ver/./}-fpm"

        echo "PHP $ver icin Phalcon yuklendi."
    else
        echo "PHP $ver icin gerekli araclar yok, atlaniyor."
    fi
done

echo -e "Tum PHP 7.x surumleri icin Phalcon 4.2.1 kurulumu tamamlandi!"
