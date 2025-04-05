🚀 Plesk + AlmaLinux için Phalcon 4.2.1 Kurulum Scripti
AlmaLinux üzerinde Plesk Panel kullanan sunuculara, PHP 7.1–7.4 sürümleri için Phalcon 4.2.1 eklentisini kolayca kurar.

🔧 Özellikler
PHP 7.1, 7.2, 7.3 ve 7.4 için otomatik kurulum

Plesk'e özel phpize, php-config, extension_dir yollarını otomatik algılar

Phalcon'u derler, kurar ve doğru .ini dosyasına ekler

Kurulum sonrası ilgili plesk-phpXX-fpm servislerini yeniden başlatır

yum kullanır (dnf değil) – AlmaLinux 8.x ve CentOS 7 uyumlu

📦 Gereksinimler
AlmaLinux 8.x veya CentOS 7

Plesk Panel kurulu olmalı

PHP 7.x sürümleri /opt/plesk/php/ dizininde yüklü olmalı

▶️ Kullanım
bash
Kopyala
Düzenle
bash plesk-phalcon-install.sh
Script çalıştırıldığında her yüklü PHP 7.x sürümü için otomatik olarak:

Gerekli bağımlılıkları kurar

Phalcon 4.2.1 kaynak kodunu indirir

Derler ve kurar

INI dosyasını oluşturur

İlgili PHP-FPM servislerini yeniden başlatır

💡 Notlar
Bu script yalnızca Phalcon 4.2.1 kurar. PHP 8.x sürümleri için Phalcon 5 kullanılmalıdır.

Plesk'te etkinleştirme işlemi otomatik yapılır, ancak kontrol için phpinfo() kullanabilirsiniz.

