import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const Color myYellow = Color(0xFFEBC92C);
  static const Color darkBg = Color(0xFF2E303A);
  static const Color containerBg = Color(0xFF24262E);

  // Controllers
  final TextEditingController _namatempatController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _suhuController = TextEditingController();

  // State untuk tanggal yang dipilih
  DateTime? _selectedDate;

  // Batasan karakter (sesuaikan dengan lebar kolom)
  static const int _maxNamaTempat = 40;
  static const int _maxLokasi = 40;
  static const int _maxSuhu = 3; // Maks 3 digit angka, misal "100"
  static const String baseUrl =
    "https://ilham.pplg1.my.id";

String namaUser = "";
int nikUser = 0;

@override
void initState() {
  super.initState();
  loadUser();
}

Future<void> loadUser() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    namaUser = prefs.getString('nama') ?? '';
    nikUser = int.tryParse(
      prefs.getString('nik') ?? '0',
    ) ?? 0;
  });
}

  // Fungsi buka DatePicker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: myYellow,
              onPrimary: Colors.black,
              surface: Color(0xFF2E303A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF24262E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Format tanggal: "Senin, 05 Jun 2025"
  String get _formattedDate {
    if (_selectedDate == null) return 'Pilih Tanggal';
    return DateFormat('EEE, dd MMM yyyy', 'id_ID').format(_selectedDate!);
  }

  @override
  void dispose() {
    _namatempatController.dispose();
    _lokasiController.dispose();
    _suhuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Atas (Kuning)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
              decoration: const BoxDecoration(
                color: myYellow,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $namaUser',
                    style: GoogleFonts.lato(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Kelola catatan perjalanan',
                    style: GoogleFonts.lato(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      // Lapisan Kuning di Belakang (Efek 3D)
                      Container(
                        width: double.infinity,
                        height: 570,
                        decoration: BoxDecoration(
                          color: myYellow,
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      // Lapisan Form Utama
                      Transform.translate(
                        offset: const Offset(-10, -10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25.0),
                          decoration: BoxDecoration(
                            color: containerBg,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              // FIELD 1: Hari/Tanggal → DatePicker
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Hari/Tanggal',
                                    style: GoogleFonts.cinzel(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  GestureDetector(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: myYellow,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formattedDate,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.calendar_today,
                                              size: 14, color: Colors.black87),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // FIELD 2: Nama Tempat (max karakter)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nama Tempat',
                                    style: GoogleFonts.cinzel(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${_namatempatController.text.length}/$_maxNamaTempat',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildLimitedTextField(
                                controller: _namatempatController,
                                maxLength: _maxNamaTempat,
                                maxLines: 3,
                                height: 90,
                                isCapsule: false,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 25),

                              // FIELD 3: Lokasi Tempat (max karakter)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Lokasi Tempat',
                                    style: GoogleFonts.cinzel(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${_lokasiController.text.length}/$_maxLokasi',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildLimitedTextField(
                                controller: _lokasiController,
                                maxLength: _maxLokasi,
                                maxLines: 3,
                                height: 90,
                                isCapsule: false,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 25),

                              // FIELD 4: Suhu Tempat + simbol °C
                              Text(
                                'Suhu Tempat',
                                style: GoogleFonts.cinzel(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              _buildSuhuField(),

                              const SizedBox(height: 35),

                              // TOMBOL ADD NOTES
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.4),
                                        offset: const Offset(-4, 4),
                                        blurRadius: 0,
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () async {
  if (_selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih tanggal terlebih dahulu'),
      ),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/mobile/catatan'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama_tempat': _namatempatController.text,
        'lokasi': _lokasiController.text,
        'suhu': _suhuController.text,
        'tanggal': _selectedDate!.toIso8601String(),
        'waktu': DateFormat('HH:mm:ss').format(DateTime.now()),
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil disimpan'),
        ),
      );

      _namatempatController.clear();
      _lokasiController.clear();
      _suhuController.clear();

      setState(() {
        _selectedDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
},
                                    child: Text(
                                      'ADD NOTES',
                                      style: GoogleFonts.cinzel(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Field dengan batas karakter
  Widget _buildLimitedTextField({
    required TextEditingController controller,
    required int maxLength,
    required int maxLines,
    required double height,
    required bool isCapsule,
    required TextInputType keyboardType,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: myYellow,
        borderRadius: BorderRadius.circular(isCapsule ? 20 : 15),
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '', // Sembunyikan counter bawaan
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Field khusus Suhu dengan suffix °C
  Widget _buildSuhuField() {
    return Container(
      width: 130,
      height: 40,
      decoration: BoxDecoration(
        color: myYellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _suhuController,
              maxLength: _maxSuhu,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_maxSuhu),
              ],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
          // Suffix °C
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              '°C',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}