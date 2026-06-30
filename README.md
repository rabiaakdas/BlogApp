# 📱 BlogApp

BlogApp, Flutter ile geliştirilen mobil uygulama ve Laravel REST API ile geliştirilen backend'den oluşan bir blog uygulamasıdır. Kullanıcılar hesap oluşturabilir, giriş yapabilir, gönderileri görüntüleyebilir, paylaşım yapabilir, yorum ekleyebilir ve gönderileri beğenebilir.

## Özellikler

- Kullanıcı kayıt olma
- Kullanıcı giriş yapma
- Kullanıcı çıkış yapma
- Kullanıcı bilgilerini görüntüleme
- Kullanıcı bilgilerini güncelleme
- Gönderi oluşturma
- Tüm gönderileri listeleme
- Gönderi detayını görüntüleme
- Gönderi güncelleme
- Gönderi silme
- Gönderilere yorum ekleme
- Bir gönderiye ait yorumları listeleme
- Yorumu güncelleme
- Yorumu silme
- Gönderi beğenme / beğeniyi kaldırma

---

## Kullanılan Teknolojiler

### Frontend
- Flutter
- Dart
- Provider
- Dio

### Backend
- Laravel
- PHP
- Laravel Sanctum
- MySQL
- REST API

---

## Proje Yapısı

```
BlogApp/
│
├── backend/      # Laravel REST API
├── frontend/     # Flutter Mobile Application
└── README.md
```

---

## Backend Kurulumu

```bash
cd backend

composer install

cp .env.example .env

php artisan key:generate

php artisan migrate

php artisan serve
```

---

## Frontend Kurulumu

```bash
cd frontend

flutter pub get

flutter run
```

Backend adresi, Flutter projesindeki API ayarları üzerinden düzenlenebilir.

---

## API İşlemleri

### Kimlik Doğrulama
- Register
- Login
- Logout
- Kullanıcı bilgilerini görüntüleme
- Kullanıcı bilgilerini güncelleme

### Gönderiler
- Gönderi oluşturma
- Gönderileri listeleme
- Gönderi detayı
- Gönderi güncelleme
- Gönderi silme

### Yorumlar
- Gönderiye yorum ekleme
- Yorumları listeleme
- Yorumu güncelleme
- Yorumu silme

### Beğeniler
- Gönderiyi beğenme
- Beğeniyi kaldırma

