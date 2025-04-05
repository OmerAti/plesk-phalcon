#!/bin/bash
# JRodix.Com - Phalcon 4.1.2 Installer for Plesk PHP 7.x by OmerAti

php_versions=("7.1" "7.2" "7.3" "7.4")

yum install -y git gcc make autoconf re2c > /dev/null 2>&1
yum install -y plesk-php71-devel
yum install -y plesk-php72-devel
yum install -y plesk-php73-devel
yum install -y plesk-php74-devel

echo ">>> Phalcon v4.1.2 kaynak kodu indiriliyor..."
if [ -d /usr/src/cphalcon ]; then
    rm -rf /usr/src/cphalcon
fi

git clone https://github.com/phalcon/cphalcon.git /usr/src/cphalcon
cd /usr/src/cphalcon
git checkout tags/v4.1.2 -b v4.1.2

if [ ! -d /usr/src/cphalcon/build ]; then
    echo "Phalcon kaynakları dogru sekilde indirilemedi."
    exit 1
fi

for ver in "${php_versions[@]}"; do
    php_prefix="/opt/plesk/php/${ver}"
    php_bin="${php_prefix}/bin/php"
    phpize="${php_prefix}/bin/phpize"
    php_config="${php_prefix}/bin/php-config"
    
    if [ -x "$php_bin" ] && [ -x "$phpize" ] && [ -x "$php_config" ]; then
        echo ">>> PHP $ver icin Phalcon kuruluyor..."

        cd /usr/src/cphalcon/build || exit
        export PATH="${php_prefix}/bin:$PATH"
        ./install --phpize "$phpize" --php-config "$php_config"

        modules_dir="$(${php_bin} -r 'echo ini_get("extension_dir");')"
        cp /usr/src/cphalcon/build/64bits/phalcon.so "${modules_dir}/"
        echo "extension=phalcon.so" > "${php_prefix}/etc/php.d/phalcon.ini"

        systemctl restart "plesk-php${ver/./}-fpm" > /dev/null 2>&1
        echo ">>> PHP $ver için Phalcon basariyla yuklendi."
    else
        echo ">>> PHP $ver icin gerekli bilesenler yok, atlaniyor."
    fi
done

echo -e "Tum uygun PHP 7.x surumleri icin Phalcon 4.1.2 kurulumu tamamlandi."
