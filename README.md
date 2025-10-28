# 🌟 Community Challenge App
Aplikasi mobile berbasis komunitas yang membantu kamu **meningkatkan produktivitas, menjaga konsistensi, dan berkompetisi sehat** dengan teman-teman!

---

## 🚀 Apa Itu Community Challenge App?
Community Challenge App dirancang untuk membuat aktivitas harian lebih menyenangkan dengan sistem **challenge, progres, dan leaderboard**.  
Setiap pengguna bisa membuat tantangan pribadi, melacak progresnya, serta berinteraksi dalam komunitas positif.

📄 *Referensi desain & implementasi terdapat dalam laporan UTS:* (https://drive.google.com/file/d/1fSrv0ur2etSdsvFXI1fEIvjYkSVpDSOH/view?usp=sharing) 

---

## 🧩 Fitur-Fitur Utama

### 🔐 1. Autentikasi — Login yang Mulus
Masuk dengan cepat dan aman!  
Begitu login berhasil, pengguna langsung diarahkan ke halaman **Home**, tanpa bisa kembali ke login page — flow yang bersih dan efisien.  
> ✨ Menggunakan `Navigator.pushReplacement()` untuk alur navigasi yang seamless.

---

### 🏠 2. Home — Ringkasan Progres & Akses Cepat
Halaman utama tempat kamu melihat **goal harian dan challenge aktif**.  
Desain berbasis card dan bottom navigation membuat semua terasa intuitif.

- 📊 Lihat progres harian
- ⚡ Navigasi cepat antar halaman
- 🎯 Klik card untuk melihat detail

---

### ✅ 3. Daily Progress — CRUD dengan Gestur Swipe
Kelola aktivitasmu secara interaktif!  
Cukup **geser item (swipe)** untuk menampilkan tombol *Edit* atau *Delete*.

- ✏️ Edit item langsung
- 🗑️ Hapus dengan sekali geser
- 🧠 State disimpan lokal (siap dihubungkan ke backend)

> Dibangun menggunakan **`flutter_slidable`** untuk UX modern dan interaktif.

---

### 🗓️ 4. Create Challenge — Form & Kalender Rentang
Buat challenge baru dengan mudah menggunakan **form interaktif dan date range picker**.

- 🧭 Pilih kategori challenge
- 📅 Tentukan durasi dengan kalender (`SfDateRangePicker`)
- 💡 Validasi otomatis agar challenge lebih relevan

---

### 🏆 5. Leaderboard — Kompetisi Sehat
Lihat siapa yang paling konsisten!  
Leaderboard menampilkan peringkat pengguna berdasarkan performa.

> Siap dikembangkan ke mode **real-time leaderboard** menggunakan backend (misalnya Firebase).

---

### 🔔 6. Notifikasi & Profil
Pantau aktivitas terbaru dan atur profilmu dengan mudah.

- 🔕 Notifikasi aktivitas penting
- 👤 Pengaturan profil & preferensi akun
- 🚪 Tombol **Logout** otomatis membersihkan navigasi history (`Navigator.pushAndRemoveUntil()`)

---

## 🎨 Desain & Tema
Aplikasi ini mengusung **tema gelap elegan (Dark Mode)** untuk pengalaman fokus dan modern.

| Elemen | Warna / Gaya |
|--------|----------------|
| Background | `#1A1A1A` – `#2C2C2E` |
| Aksen | `#007AFF` (biru iOS style) |
| Font | Inter / System UI |
| Layout | Card-based, clean spacing |

---

## 🛠️ Teknologi yang Digunakan
- **Flutter Framework**
- **Package utama:**
  - `flutter_slidable` — interaksi CRUD dengan gestur
  - `syncfusion_flutter_datepicker` — kalender rentang tanggal
- **State Management:** Stateful Widget (local state)

---

## ⚙️ Cara Menjalankan (Quick Start)

```bash
# 1️⃣ Clone repository
git clone <repo-url>

# 2️⃣ Masuk ke folder project
cd community_challenge_app

# 3️⃣ Install dependencies
flutter pub get

# 4️⃣ Jalankan aplikasi
flutter run
