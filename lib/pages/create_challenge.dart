import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final List<String> _categoryOptions = [
    'Daily Productivity Task',
    'Weekly Reading Goal',
    'Tilawah Al-Quran Harian',
    'Olahraga',
    'Belajar Hal Baru',
  ];
  late String _selectedCategory;
  DateTimeRange? _selectedDateRange; // <-- STATE UNTUK TANGGAL
  bool _isCalendarVisible = false; // <-- STATE UNTUK MENAMPILKAN KALENDER

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categoryOptions[0];
  }

  // --- FUNGSI LAMA (showDateRangePicker) TIDAK DIGUNAKAN LAGI ---
  // Kita akan ganti logikanya di _buildDateRangePicker
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                const SizedBox(height: 24),
                _buildSectionTitle('Nama Challenge'),
                const SizedBox(height: 12),
                _buildTextField(hint: 'Contoh: Baca Buku 30 Menit'),
                const SizedBox(height: 24),
                _buildSectionTitle('Kategori'),
                const SizedBox(height: 12),
                _buildCategoryDropdown(),
                const SizedBox(height: 24),
                _buildSectionTitle('Target'),
                const SizedBox(height: 12),
                _buildTextField(
                  hint: 'Contoh: 30 hari atau 50 halaman',
                  keyboardType: TextInputType.text,
                ),
                // --- TAMBAHAN UNTUK DURASI ---
                const SizedBox(height: 24),
                _buildSectionTitle('Durasi Challenge'),
                const SizedBox(height: 12),
                _buildDateRangePicker(),
                // --- KARTU KALENDER YANG MUNCUL ---
                // PERBAIKAN: Bungkus dengan Center
                if (_isCalendarVisible)
                  Center(
                    child: _buildCalendarCard(),
                  ),
                // --------------------------------
                const SizedBox(height: 40),
                _buildCreateButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // PERBAIKAN: Arahkan ke Home (halaman paling awal)
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
            ),
          ),
          const Text('Buat Challenge Baru',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 44), // Untuk menyeimbangkan tombol kembali
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          color: Colors.grey.shade300,
          fontSize: 16,
          fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField(
      {required String hint, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        items: _categoryOptions.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedCategory = newValue!;
          });
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        icon:
            const Icon(Icons.arrow_drop_down, color: Colors.white), // Ikon panah
        dropdownColor: const Color(0xFF2C2C2E), // Warna background menu
      ),
    );
  }

  // --- WIDGET PEMILIH TANGGAL DIPERBARUI ---
  Widget _buildDateRangePicker() {
    // Helper function untuk format tanggal
    String formatDate(DateTime date) {
      return "${date.day}/${date.month}/${date.year}";
    }

    String dateRangeText;
    if (_selectedDateRange == null) {
      dateRangeText = 'Pilih tanggal mulai & selesai';
    } else {
      dateRangeText =
          '${formatDate(_selectedDateRange!.start)} - ${formatDate(_selectedDateRange!.end)}';
    }

    return GestureDetector(
      // Toggle visibilitas kalender saat ditekan
      onTap: () {
        setState(() {
          _isCalendarVisible = !_isCalendarVisible;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 12),
                Text(
                  dateRangeText,
                  style: TextStyle(
                    color: _selectedDateRange == null
                        ? Colors.grey.shade600
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Ganti ikon panah berdasarkan visibilitas
            Icon(
              _isCalendarVisible
                  ? Icons.arrow_drop_up
                  : Icons.arrow_drop_down,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
  // ----------------------------------------

  // --- WIDGET BARU UNTUK KARTU KALENDER ---
  Widget _buildCalendarCard() {
    return Container(
      width: 360,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(24),
        // PERBAIKAN: Shadow dihapus
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.25),
        //     offset: const Offset(0, 4),
        //     blurRadius: 20,
        //     spreadRadius: 0,
        //   ),
        // ],
      ),
      child: ClipRRect(
        // Kita gunakan ClipRRect agar kalender di dalamnya ikut melengkung
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 400,
          child: Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF007AFF),
                onPrimary: Colors.white,
                surface: Color(0xFF2C2C2E),
                onSurface: Colors.white,
              ),
            ),
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              startRangeSelectionColor: const Color(0xFF007AFF),
              endRangeSelectionColor: const Color(0xFF007AFF),
              rangeSelectionColor: const Color(0x33007AFF),
              todayHighlightColor: const Color(0xFF007AFF),
              backgroundColor: const Color(0xFF2C2C2E),
              // --- Styling Teks ---
              headerStyle: const DateRangePickerHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              monthViewSettings: const DateRangePickerMonthViewSettings(
                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                  textStyle: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              monthCellStyle: const DateRangePickerMonthCellStyle(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                todayTextStyle: TextStyle(
                  // PERBAIKAN: Ubah warna teks "hari ini" jadi putih
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              yearCellStyle: const DateRangePickerYearCellStyle(
                textStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(
                    color: Color(0xFF007AFF), fontWeight: FontWeight.bold),
              ),
              // --- Logika ---
              initialSelectedRange: _selectedDateRange == null
                  ? null
                  : PickerDateRange(
                      _selectedDateRange!.start, _selectedDateRange!.end),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  final range = args.value as PickerDateRange;
                  if (range.startDate != null && range.endDate != null) {
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: range.startDate!,
                        end: range.endDate!,
                      );
                      // PERBAIKAN: Tutup kalender setelah rentang penuh dipilih
                      _isCalendarVisible = false;
                    });
                  } else if (range.startDate != null) {
                    // Jika baru memilih tanggal mulai
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: range.startDate!,
                        end: range.startDate!, // Set end = start sementara
                      );
                    });
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Logika untuk membuat challenge
          Navigator.pop(context); // Kembali setelah dibuat
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Buat Challenge',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


