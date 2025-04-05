🚀 Phalcon 4.2.1 Kurulum Scripti (Plesk + AlmaLinux)
Plesk Panel yüklü AlmaLinux 8.x veya CentOS 7 sunucularında, PHP 7.1-7.4 sürümleri için Phalcon 4.2.1 eklentisini otomatik olarak kurar.

📦 Ön Koşullar
AlmaLinux 8.x veya CentOS 7 işletim sistemi

Plesk Panel kurulu olmalı

/opt/plesk/php/ dizininde bir veya daha fazla PHP 7.x sürümü yüklü olmalı

Root veya sudo yetkilerine sahip kullanıcı

🔧 Kurulum
Scripti indirin:

wget https://raw.githubusercontent.com/OmerAti/plesk-phalcon/main/plesk-phalcon-install.sh
Çalıştırılabilir yapın:

chmod +x plesk-phalcon-install.sh
Scripti çalıştırın:

sudo ./plesk-phalcon-install.sh
🛠️ Scriptin Yaptıkları
Sistemde yüklü olan tüm PHP 7.x sürümlerini tespit eder

Gerekli bağımlılıkları yükler (gcc, make, php-devel vb.)

Phalcon 4.2.1 kaynak kodunu indirir ve derler

Her PHP sürümü için ayrı ayrı eklentiyi kurar

Plesk'in PHP yapılandırmasına uygun şekilde .ini dosyası oluşturur

İlgili PHP-FPM servislerini yeniden başlatır

✔️ Kurulum Sonrası Kontrol
Kurulumun başarılı olduğunu doğrulamak için:

Plesk Panel'de bir PHP sayfası oluşturun:

<?php phpinfo(); ?>
Sayfayı tarayıcıda açın ve "Phalcon" modülünün listelendiğini kontrol edin.

⚠️ Önemli Notlar
Bu script yalnızca PHP 7.1-7.4 sürümleri ile çalışır

PHP 8.x için Phalcon 5.x kullanmanız gerekir

Script sadece AlmaLinux 8.x ve CentOS 7 ile test edilmiştir

Kurulum sırasında internet bağlantısı gereklidir (bağımlılıklar indirilecek)

📜 Lisans
Bu script MIT lisansı ile lisanslanmıştır. Detaylar için LICENSE dosyasına bakınız.
