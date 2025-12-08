import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart'; // (Pastikan impor ini ada)

class CreateChallengePage extends StatefulWidget {
  final DocumentSnapshot? challengeToEdit;
  final String? initialTitle;
  final String? initialDescription;

  const CreateChallengePage({
    super.key,
    this.challengeToEdit,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  List<Map<String, dynamic>> _categoryOptions = [];
  Map<String, dynamic>? _selectedCategoryMap;
  bool _isLoadingCategories = true;

  DateTimeRange? _selectedDateRange;
  bool _isCalendarVisible = false;
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isLoading = false;
  bool _isEditMode = false;
  String? _editingChallengeId;

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ibadah':
        return Icons.mosque_outlined;
      case 'kesehatan':
        return Icons.directions_run_outlined;
      case 'produktifitas':
        return Icons.lightbulb_outline;
      case 'alquran':
      case 'quran':
        return Icons.book_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();
      if (snapshot.docs.isEmpty) {
        setState(() => _isLoadingCategories = false);
        return;
      }

      final categories = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Tanpa Nama',
          'iconName': data['icon'] ?? 'default',
        };
      }).toList();

      setState(() {
        _categoryOptions = categories;
        _isLoadingCategories = false;
        _setupInitialData();
      });
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() => _isLoadingCategories = false);
    }
  }

  void _setupInitialData() {
    if (widget.challengeToEdit != null && _categoryOptions.isNotEmpty) {
      _isEditMode = true;
      final data = widget.challengeToEdit!.data() as Map<String, dynamic>;
      _editingChallengeId = widget.challengeToEdit!.id;

      _namaController.text = data['title'] ?? '';
      _deskripsiController.text = data['description'] ?? '';

      final String categoryName = data['category'] ?? '';
      _selectedCategoryMap = _categoryOptions.firstWhere(
        (map) => map['name'] == categoryName,
        orElse: () => _categoryOptions[0],
      );

      final Timestamp startTimestamp = data['completedDays'] ?? Timestamp.now();
      final int duration = data['duration'] ?? 1;
      final DateTime startDate = startTimestamp.toDate();
      final DateTime endDate = startDate.add(Duration(days: duration - 1));
      _selectedDateRange = DateTimeRange(start: startDate, end: endDate);
    } else if (_categoryOptions.isNotEmpty) {
      // Set default untuk Mode Create (tapi jangan pilih otomatis)
      // _selectedCategoryMap = _categoryOptions[0]; // <-- Hapus ini agar default-nya "Pilih"
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _saveChallenge() async {
    // ... (Fungsi _saveChallenge kamu tidak berubah)
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama challenge tidak boleh kosong')),
      );
      return;
    }
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih durasi challenge')),
      );
      return;
    }
    if (_selectedCategoryMap == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harap pilih kategori')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final durationInDays =
        _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays +
        1;
    final startDate = Timestamp.fromDate(_selectedDateRange!.start);

    final Map<String, dynamic> challengeData = {
      'title': _namaController.text,
      'category': _selectedCategoryMap!['name'],
      'description': _deskripsiController.text,
      'duration': durationInDays,
      'completedDays': startDate,
      'creator': user.email,
    };

    // ... (di dalam _saveChallenge)
    try {
      if (_isEditMode) {
        // ... (logika edit mode tidak berubah)
        await FirebaseFirestore.instance
            .collection('challenges')
            .doc(_editingChallengeId)
            .update(challengeData);
      } else {
        // --- INI KODE BARU UNTUK CREATE ---
        challengeData['progress'] = 0;
        challengeData['members'] = 1; // Mulai dari 1 (si pembuat)

        // 1. Otomatis tambahkan UID pembuat ke daftar peserta
        challengeData['participantUIDs'] = [user.uid];

        // 2. Buat challenge baru
        final newChallenge = await FirebaseFirestore.instance
            .collection('challenges')
            .add(challengeData);

        // 3. (PENTING) Buat juga dokumen 'participants' untuk si pembuat
        //    agar dia langsung muncul di leaderboard
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>;

        final String participantDocId = '${user.uid}_${newChallenge.id}';
        await FirebaseFirestore.instance
            .collection('participants')
            .doc(participantDocId)
            .set({
              'score': 0, // Mulai dari 0 poin
              'userId': user.uid,
              'challengeId': newChallenge.id,
              'displayName': userData['displayName'] ?? 'User',
              'photoUrl': userData['photoUrl'] ?? '',
            });
      }
      // ...

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Challenge diperbarui!' : 'Challenge dibuat!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Fungsi build tidak berubah, masih memanggil _buildCategoryDropdown)
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
                _buildTextField(
                  hint: 'Contoh: Baca Buku 30 Menit',
                  controller: _namaController,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Kategori'),
                const SizedBox(height: 12),
                _buildCategoryDropdown(), // <-- PANGGIL FUNGSI YANG KITA MODIF
                const SizedBox(height: 24),
                _buildSectionTitle('Deskripsi'),
                const SizedBox(height: 12),
                _buildTextField(
                  hint: 'Tulis deskripsi singkat challenge...',
                  controller: _deskripsiController,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Durasi Challenge'),
                const SizedBox(height: 12),
                _buildDateRangePicker(),
                if (_isCalendarVisible) Center(child: _buildCalendarCard()),
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
    // ... (Tidak berubah)
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Cukup pop
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Text(
            _isEditMode ? 'Edit Challenge' : 'Buat Challenge Baru',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    // ... (Tidak berubah)
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey.shade300,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
  }) {
    // ... (Tidak berubah)
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: keyboardType == TextInputType.multiline ? null : 1,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }

  // --- 9. FUNGSI DROPDOWN KATEGORI (VERSI MODAL) ---
  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        // ... (Tampilan loading tetap sama)
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text("Memuat kategori...", style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    // GANTI JADI TOMBOL PALSU
    return GestureDetector(
      onTap: () {
        // Panggil fungsi untuk memunculkan modal
        _showCategoryPicker(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E), // Ganti warna background kotak
          borderRadius: BorderRadius.circular(16), // Ganti kelengkungan sudut
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tampilkan kategori yang dipilih
            _selectedCategoryMap == null
                ? Text(
                    // Teks default jika belum ada yg dipilih
                    'Pilih Kategori',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Row(
                    // Tampilkan ikon dan nama jika sudah dipilih
                    children: [
                      Icon(
                        _getIconForCategory(_selectedCategoryMap!['iconName']),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedCategoryMap!['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
            // Ikon panah
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // --- 10. FUNGSI BARU UNTUK MENAMPILKAN MODAL ---
  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E), // Warna background modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.5, // Setengah layar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Modal
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Pilih Kategori',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Color(0xFF2C2C2E)),
              // List Kategori
              Expanded(
                child: ListView.builder(
                  itemCount: _categoryOptions.length,
                  itemBuilder: (context, index) {
                    final option = _categoryOptions[index];
                    final isSelected =
                        _selectedCategoryMap?['id'] == option['id'];

                    return ListTile(
                      leading: Icon(
                        _getIconForCategory(option['iconName']),
                        color: isSelected ? Color(0xFF007AFF) : Colors.white,
                      ),
                      title: Text(
                        option['name'],
                        style: TextStyle(
                          color: isSelected ? Color(0xFF007AFF) : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        // Set state & tutup modal
                        setState(() {
                          _selectedCategoryMap = option;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Sisa fungsi helper (tidak berubah) ---
  Widget _buildDateRangePicker() {
    // ... (Tidak berubah)
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
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
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
            Icon(
              _isCalendarVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    // ... (Tidak berubah)
    return Container(
      width: 360,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
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
                textStyle: TextStyle(color: Colors.white, fontSize: 14),
                todayTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              yearCellStyle: const DateRangePickerYearCellStyle(
                textStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              initialSelectedRange: _selectedDateRange == null
                  ? null
                  : PickerDateRange(
                      _selectedDateRange!.start,
                      _selectedDateRange!.end,
                    ),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  final range = args.value as PickerDateRange;
                  if (range.startDate != null && range.endDate != null) {
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: range.startDate!,
                        end: range.endDate!,
                      );
                      _isCalendarVisible = false;
                    });
                  } else if (range.startDate != null) {
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: range.startDate!,
                        end: range.startDate!,
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
    // ... (Tidak berubah)
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChallenge,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                _isEditMode ? 'Update Challenge' : 'Buat Challenge',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
