# 🚀 Phalcon 4.2.1 Kurulumu - Plesk + AlmaLinux/CentOS

## 📋 Proje Açıklaması

Bu otomasyon scripti, Plesk Panel yüklü AlmaLinux 8.x veya CentOS 7 sunucularında PHP 7.1-7.4 sürümleri için Phalcon PHP framework 4.2.1 sürümünün kurulumunu gerçekleştirir.

## ✨ Temel Özellikler

- 🛠️ **Otomatik Tespit**: Plesk'in özel PHP dizinlerini (`/opt/plesk/php/`) otomatik tanır
- 🔄 **Çoklu PHP Desteği**: Tek seferde tüm PHP 7.x sürümlerine kurulum yapar
- 📦 **Bağımlılık Yönetimi**: Gerekli tüm paketleri otomatik kurar
- 🔧 **Servis Yönetimi**: PHP-FPM servislerini otomatik restart eder

## 🧰 Teknik Gereksinimler

| Bileşen | Minimum Sürüm |
|---------|--------------|
| İşletim Sistemi | AlmaLinux 8.x / CentOS 7.x |
| Plesk Panel | Obsidian 18.0+ |
| Disk Alanı | 500MB boş alan |
| RAM | 1GB (2GB önerilir) |
| PHP Versiyonları | 7.1, 7.2, 7.3, 7.4 |

## 🚀 Kurulum Kılavuzu


```bash
wget https://raw.githubusercontent.com/OmerAti/plesk-phalcon/refs/heads/main/plesk-phalcon.sh
chmod +x plesk-phalcon.sh
bash plesk-phalcon.sh
