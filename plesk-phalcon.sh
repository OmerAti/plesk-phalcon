#!/bin/bash

PHP_VERSION="${1:-8.4}"
PHALCON_VERSION="${PHALCON_VERSION:-5.23.0}"
PSR_VERSION="${PSR_VERSION:-1.2.0}"
PHALCON_OPT="${PHALCON_OPT:--O1}"

PHP_DIR="/opt/plesk/php/${PHP_VERSION}"
PHP_BIN="${PHP_DIR}/bin/php"
PECL_BIN="${PHP_DIR}/bin/pecl"
PHPIZE_BIN="${PHP_DIR}/bin/phpize"
PHP_CONFIG_BIN="${PHP_DIR}/bin/php-config"
INI_DIR="${PHP_DIR}/etc/php.d"
PHP_INI="${PHP_DIR}/etc/php.ini"
SRC_DIR="/tmp/phalcon-src-${PHP_VERSION}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Hata: Root yetkisi gerekiyor!" >&2
  exit 1
fi

if [ ! -x "${PHP_BIN}" ]; then
  echo "Hata: ${PHP_BIN} bulunamadi. Kurulu PHP surumleri:" >&2
  ls -1 /opt/plesk/php >&2
  exit 1
fi

LOG_FILE="/var/log/plesk_phalcon_install_$(date +%Y%m%d%H%M%S)_php${PHP_VERSION}.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

EXT_DIR="$("${PHP_BIN}" -r 'echo ini_get("extension_dir");' 2>/dev/null)"
if [ -z "${EXT_DIR}" ] || [ ! -d "${EXT_DIR}" ]; then
  echo "Hata: extension_dir cozumlenemedi (${EXT_DIR})" >&2
  exit 1
fi

ext_loaded() {
  "${PHP_BIN}" -m 2>/dev/null | grep -qix "$1"
}

# Modulu tek kaynaktan aktif eder: php.d/NAME.ini.
# PECL, php.ini'ye de 'extension=NAME.so' yazabiliyor; ikisi bir arada
# "Module already loaded" uyarisi urettigi icin php.ini tarafi yorum alinir.
enable_extension() {
  local name="$1"
  printf 'extension=%s.so\n' "${name}" > "${INI_DIR}/${name}.ini" || return 1
  if grep -qs "^[[:space:]]*extension[[:space:]]*=[[:space:]]*${name}\.so" "${PHP_INI}"; then
    echo "php.ini icindeki ${name}.so satiri yorum aliniyor (cift yuklenme onlemi)"
    sed -ri "s|^([[:space:]]*)extension[[:space:]]*=[[:space:]]*${name}\.so|;\\1extension=${name}.so|" "${PHP_INI}"
  fi
  ext_loaded "${name}"
}

install_psr() {
  local ver="$1"
  if ext_loaded psr; then
    echo "psr zaten yuklu: $("${PHP_BIN}" -r 'echo phpversion("psr");')"
    return 0
  fi
  echo "PSR ${ver} PECL ile kuruluyor..."
  if ! "${PECL_BIN}" install -f "psr-${ver}" </dev/null; then
    echo "Hata: psr-${ver} PECL ile kurulamadi" >&2
    return 1
  fi
  enable_extension psr || { echo "Hata: psr yuklenemedi" >&2; return 1; }
  echo "psr aktif, surum: $("${PHP_BIN}" -r 'echo phpversion("psr");')"
}
build_phalcon() {
  local ver="$1" opt="$2" tgz so_file

  so_file="${EXT_DIR}/phalcon.so"
  if ext_loaded phalcon; then
    echo "phalcon zaten yuklu: $("${PHP_BIN}" -r 'echo phpversion("phalcon");')"
    return 0
  fi

  rm -rf "${SRC_DIR}" && mkdir -p "${SRC_DIR}" || return 1
  cd "${SRC_DIR}" || return 1

  echo "Phalcon ${ver} kaynak paketi indiriliyor..."
  if ! "${PECL_BIN}" download "phalcon-${ver}" </dev/null; then
    echo "Hata: phalcon-${ver} indirilemedi" >&2
    return 1
  fi
  tgz=$(ls -1 "phalcon-${ver}".tgz "phalcon-${ver}".tar.gz 2>/dev/null | head -1)
  [ -f "${tgz}" ] || { echo "Hata: indirilen paket bulunamadi" >&2; return 1; }
  tar -xzf "${tgz}" || { echo "Hata: paket acilamadi" >&2; return 1; }
  cd "phalcon-${ver}" || { echo "Hata: phalcon-${ver} dizini yok" >&2; return 1; }

  echo "phpize + configure..."
  "${PHPIZE_BIN}" >/dev/null || { echo "Hata: phpize basarisiz" >&2; return 1; }
  ./configure --with-php-config="${PHP_CONFIG_BIN}" >/dev/null 2>&1 \
    || { echo "Hata: configure basarisiz" >&2; return 1; }

  echo "configure sonrasi CFLAGS: $(grep -m1 '^CFLAGS' Makefile)"
  sed -i "s/-O2/${opt}/g" Makefile
  echo "${opt} uygulandi        : $(grep -m1 '^CFLAGS' Makefile)"
  echo "bellek (derleme oncesi) : $(free -m | awk 'NR==2{print $7" MB kullanilabilir"}')"

  echo "Derleniyor (tek is parcali, birkac dakika surebilir)..."
  if ! make; then
    echo "Hata: make basarisiz" >&2
    return 1
  fi
  if ! make install; then
    echo "Hata: make install basarisiz" >&2
    return 1
  fi
  [ -f "${so_file}" ] || { echo "Hata: ${so_file} olusmadi" >&2; return 1; }
  echo "olusan modul: $(ls -la "${so_file}")"

  enable_extension phalcon || { echo "Hata: phalcon yuklenemedi" >&2; return 1; }
  echo "phalcon aktif, surum: $("${PHP_BIN}" -r 'echo phpversion("phalcon");')"
}

check_build_deps() {
  local pkg_prefix="plesk-php${PHP_VERSION//./}"
  local f
  for f in "${PHPIZE_BIN}" "${PHP_CONFIG_BIN}" "${PECL_BIN}"; do
    if [ ! -x "${f}" ]; then
      echo "Derleme araclari eksik: ${pkg_prefix}-devel / ${pkg_prefix}-pear kuruluyor..."
      yum install -y "${pkg_prefix}-devel" "${pkg_prefix}-pear" >>"${LOG_FILE}" 2>&1
      break
    fi
  done
  if ! command -v gcc >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
    echo "gcc/make eksik, kuruluyor..."
    yum install -y gcc make autoconf automake libtool >>"${LOG_FILE}" 2>&1
  fi
}

echo "=================================================="
echo "PHP ${PHP_VERSION} -> Phalcon ${PHALCON_VERSION} (${PHALCON_OPT}) + PSR ${PSR_VERSION}"
echo "Baslangic: $(date)"
echo "php           : $("${PHP_BIN}" -v | head -1)"
echo "extension_dir : ${EXT_DIR}"
echo "php.d         : ${INI_DIR}"
echo "=================================================="

check_build_deps
"${PECL_BIN}" channel-update pecl.php.net >>"${LOG_FILE}" 2>&1

if ! install_psr "${PSR_VERSION}"; then
  echo "PSR kurulamadi: Phalcon PSR arayuzleri olmadan calismaz." >&2
  exit 1
fi

if ! build_phalcon "${PHALCON_VERSION}" "${PHALCON_OPT}"; then
  exit 1
fi

rm -rf "${SRC_DIR}"

FPM_UNIT="plesk-php${PHP_VERSION//./}-fpm"
if systemctl is-active --quiet "${FPM_UNIT}" 2>/dev/null; then
  echo "${FPM_UNIT} graceful reload ediliyor (reload = aktif istekler kesilmez)..."
  systemctl reload "${FPM_UNIT}"
elif systemctl cat "${FPM_UNIT}" >/dev/null 2>&1; then
  echo "${FPM_UNIT} aktif degildi, start ediliyor..."
  systemctl start "${FPM_UNIT}"
fi
sleep 2
systemctl cat "${FPM_UNIT}" >/dev/null 2>&1 && echo "${FPM_UNIT} durumu: $(systemctl is-active "${FPM_UNIT}")"

echo "--------------------------------------------------"
echo "Son durum kontrolu (CLI):"
"${PHP_BIN}" -m | grep -Ei '^(psr|phalcon)$' || echo "Modul yok"
"${PHP_BIN}" --ri phalcon 2>/dev/null | head -8
echo "Detayli log: ${LOG_FILE}"
