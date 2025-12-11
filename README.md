# 🌟 Community Challenge App

Aplikasi mobile berbasis komunitas yang membantu kamu **meningkatkan produktivitas, menjaga konsistensi, dan berkompetisi sehat** dengan teman-teman!

> 🚀 **Update UAS:** Versi ini telah dikembangkan lebih lanjut dengan integrasi **RESTful API Publik (Google Books)** dan sinkronisasi data *real-time* menggunakan **Firebase**.

---

## 🚀 Apa Itu Community Challenge App?
Community Challenge App dirancang untuk membuat aktivitas harian lebih menyenangkan dengan sistem **challenge, progres, dan leaderboard**.  
Setiap pengguna bisa membuat tantangan pribadi, melacak progresnya, serta berinteraksi dalam komunitas positif. Aplikasi ini kini mendukung pengambilan data dinamis dari internet untuk pengalaman yang lebih kaya.

📄 *Referensi desain & implementasi terdapat dalam [laporan UTS](https://drive.google.com/file/d/1fSrv0ur2etSdsvFXI1fEIvjYkSVpDSOH/view?usp=sharing)* .
📄 *Laporan Hasil Akhir Project [laporan UAS](https://drive.google.com/file/d/1zlf_1wEXrufj3GNqvKyiJbCapPXIafc_/view?usp=sharing)* 

## 🧩 Fitur-Fitur Utama

### 🔐 1. Autentikasi — Firebase Auth
Masuk dengan cepat dan aman menggunakan email!  
Sistem autentikasi kini terintegrasi penuh dengan **Firebase Authentication**.
> ✨ Login, Register, dan Logout dikelola secara *secure* dan *real-time*.

---

### 📚 2. Integrasi REST API (Fitur Unggulan)
Aplikasi tidak lagi menggunakan data dummy statis, melainkan mengambil data langsung dari server eksternal menggunakan **Google Books API**:

- **Pencarian Buku:** Cari buku favoritmu berdasarkan judul secara *real-time* (Parameter dinamis).
- **Detail Buku:** Lihat deskripsi lengkap, penulis, dan cover buku dari data JSON API.
- **Integrasi Fitur:** Temukan buku dan langsung jadikan sebagai *Challenge* baru (Judul & Deskripsi form akan terisi otomatis).

---

### 🏠 3. Home & Dashboard
Halaman utama tempat kamu melihat **goal harian dan challenge aktif**.  
Data profil (Nama & Foto) diambil secara *stream* dari database.

- 📊 Lihat progres harian (dihitung otomatis dari partisipasi)
- ⚡ Navigasi cepat antar halaman
- 🎯 Klik kategori **Reading** untuk mengakses fitur pencarian buku online.

---

### ✅ 4. Daily Progress — Real-time Database
Kelola aktivitasmu secara interaktif!  
Data tersimpan aman di **Cloud Firestore**.

- ✏️ **Swipe Actions:** Geser untuk keluar dari challenge (`flutter_slidable`).
- 🔄 **Sinkronisasi:** Progres yang kamu update akan langsung terlihat oleh teman-temanmu.

---

### 🗓️ 5. Create Challenge — Auto-Fill & Date Picker
Buat challenge baru dengan mudah. Kini lebih pintar!

- 🧭 **Integrasi API:** Jika membuat challenge dari halaman Buku, form akan terisi otomatis.
- 📅 Tentukan durasi dengan kalender (`SfDateRangePicker`).
- 💾 Data tersimpan ke Firestore dan bisa diikuti oleh pengguna lain.

---

### 🏆 6. Leaderboard — Kompetisi Real-time
Lihat siapa yang paling konsisten!  
Leaderboard menampilkan peringkat pengguna berdasarkan **Score** yang tersimpan di database.

- 🥇 **Dynamic Podium:** Tampilan khusus untuk Top 3.
- 🖼️ **Optimasi Gambar:** Foto profil dimuat cepat menggunakan `cached_network_image` agar hemat kuota.

---

### 🔔 7. Notifikasi & Profil
- 🔔 **Notifikasi:** Riwayat aktivitas (Naik peringkat, teman bergabung) diambil dari koleksi notifikasi.
- 👤 **Edit Profil:** Ubah nama dan foto profil, data langsung terupdate di seluruh aplikasi.

---

## 🎨 Desain & Tema
Aplikasi ini mengusung **tema gelap elegan (Dark Mode)** untuk pengalaman fokus dan modern.

| Elemen | Warna / Gaya |
|--------|----------------|
| Background | `#1A1A1A` – `#2C2C2E` |
| Aksen | `#007AFF` (biru iOS style) |
| Font | Inter / System UI |
| Feedback | Circular Progress Indicator & Snackbar |

---

## 🛠️ Teknologi yang Digunakan

### Core & Backend
- **Flutter Framework** (Dart)
- **Firebase:**
  - `firebase_auth` (Autentikasi)
  - `cloud_firestore` (Database NoSQL Real-time)

### Networking & API (Syarat UAS)
- **`http`**: Melakukan GET Request ke Google Books API.
- **JSON Serialization**: Parsing data JSON menjadi Model Object Dart.
- **Asynchronous**: Menggunakan `FutureBuilder` dan `StreamBuilder` untuk menangani *Loading, Success, & Error State*.

### UI & Packages
- `flutter_slidable` — Interaksi geser
- `syncfusion_flutter_datepicker` — Kalender
- `cached_network_image` — Caching gambar

---

## ⚙️ Cara Menjalankan (Quick Start)

Pastikan kamu memiliki Flutter SDK dan konfigurasi Firebase (`firebase_options.dart`) yang valid.

```bash
# 1️⃣ Clone repository
git clone <repo-url>

# 2️⃣ Masuk ke folder project
cd community_challenge_app

# 3️⃣ Install dependencies
flutter pub get

# 4️⃣ Jalankan aplikasi
flutter run
