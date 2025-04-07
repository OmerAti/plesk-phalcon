#!/bin/bash
# Plesk Phalcon 4.1.2 Installer

echo "--------------------------------------------------"
echo "JRodix Internet Hizmetleri"
echo "Omer ATABER - OmerAti"
echo "--------------------------------------------------"
echo "Phalcon 4.1.2 Kurulumu"
echo "--------------------------------------------------"


if [ "$(id -u)" -ne 0 ]; then
  echo "Hata: Root yetkisi gerekiyor!" >&2
  exit 1
fi


LOG_FILE="/var/log/plesk_phalcon_install_$(date +%Y%m%d%H%M%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "Baslangic: $(date)"


install_psr() {
  local version=$1
  local php_dir="/opt/plesk/php/${version}"
  
  echo "PHP ${version} icin PSR kurulumu denetleniyor..."
  

  if "${php_dir}/bin/php" -m | grep -q psr; then
    echo "PSR zaten yuklu"
    return 0
  fi


echo "PHP 7.4 için bağımlılıklar kontrol ediliyor..."

yum install -y "plesk-php7.4-devel" "plesk-php7.4-pear" >> "${LOG_FILE}" 2>&1
yum install -y git gcc make autoconf re2c >> "${LOG_FILE}" 2>&1
if [[ $? -ne 0 ]]; then
  echo "plesk-php7.4-* paketleri bulunamadi, alternatif olarak plesk-php74-* deneniyor..."
  yum install -y "plesk-php74-devel" "plesk-php74-pear" >> "${LOG_FILE}" 2>&1
  yum install -y git gcc make autoconf re2c >> "${LOG_FILE}" 2>&1
fi


  echo "PECL kanali guncelleniyor..."
  "${php_dir}/bin/pecl" channel-update pecl.php.net >> "${LOG_FILE}" 2>&1
  

  for attempt in {1..3}; do
    echo "PSR kurulum denemesi #${attempt}"
    "${php_dir}/bin/pecl" install -f psr >> "${LOG_FILE}" 2>&1
    
    if [ $? -eq 0 ]; then
      echo "extension=psr.so" > "${php_dir}/etc/php.d/psr.ini"

      

      if "${php_dir}/bin/php" -m | grep -q psr; then
        echo "PSR kurulumu basarili"
        return 0
      fi
    fi
    
    sleep 2
  done
  
  echo "PSR kurulumu basarisiz (3 deneme)"
  return 1
}


install_phalcon() {
  local version=$1
  local php_dir="/opt/plesk/php/${version}"
  
  cd /tmp || return 1
  
  echo "Phalcon 4.1.2 indiriliyor..."
  if [ ! -f "v4.1.2.tar.gz" ]; then
    wget -q --tries=3 --timeout=30 https://github.com/phalcon/cphalcon/archive/refs/tags/v4.1.2.tar.gz -O v4.1.2.tar.gz
  fi
  
  tar xzf v4.1.2.tar.gz
  cd cphalcon-4.1.2/build || return 1
  yum install -y git gcc make autoconf re2c > /dev/null 2>&1
  echo "Phalcon derleniyor..."
  ./install --phpize "${php_dir}/bin/phpize" \
           --php-config "${php_dir}/bin/php-config" >> "${LOG_FILE}" 2>&1
  
  if [ $? -ne 0 ]; then
    echo "Derleme hatasi"
    return 1
  fi

  echo "extension=phalcon.so" > "${php_dir}/etc/php.d/phalcon.ini"

  

  if "${php_dir}/bin/php" -m | grep -q phalcon; then
    echo "Phalcon basariyla yuklendi"
    return 0
  else
    echo "Phalcon yuklenemedi"
    return 1
  fi
}


version=7.4
PHP_DIR="/opt/plesk/php/${version}"

if [ ! -d "${PHP_DIR}" ]; then
  echo "PHP ${version} bulunamadi, atlaniyor..."
  exit 1
fi

echo "PHP ${version} isleniyor..."


if install_psr "${version}"; then

  install_phalcon "${version}"
else
  echo "PHP ${version}: PSR olmadan Phalcon calismaz!"
fi


cd /tmp && rm -rf v4.1.2.tar.gz cphalcon-4.1.2

echo "Kurulum tamamlandi"
echo "Detayli log: ${LOG_FILE}"
echo "Son durum kontrolü:"

[ -d "/opt/plesk/php/${version}" ] && \
echo -n "PHP ${version}: " && \
/opt/plesk/php/${version}/bin/php -m | grep -E 'phalcon|psr' || echo "Modul yok"
