import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk FilteringTextInputFormatter
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Untuk menghasilkan ID unik
import 'package:provider/provider.dart';
import '../../models/transaction.dart' as mymodel;
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart'; // Import UserProvider
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Untuk ikon FontAwesome
import '../../models/category.dart'; // Pastikan path ini benar untuk model Category Anda

class AddEditRecordPage extends StatefulWidget {
  final mymodel.Transaction? transactionToEdit;

  const AddEditRecordPage({super.key, this.transactionToEdit});

  @override
  State<AddEditRecordPage> createState() => _AddEditRecordPageState();
}

class _AddEditRecordPageState extends State<AddEditRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  // State untuk form
  mymodel.TransactionType _selectedType = mymodel.TransactionType.expense; // Default expense
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory; // ID kategori
  String? _selectedFromAccount; // Nama akun asal
  String? _selectedToAccount; // Nama akun tujuan

  // Dummy list akun (Nanti ini akan diganti dengan AccountProvider)
  final List<String> _dummyAccounts = ['Cash', 'Bank Account', 'E-Wallet'];

  // Dummy categories. Idealnya ini dari CategoryProvider atau global static list
  final List<Category> _expenseCategories = [
    Category(id: 'cat_belanja', name: 'Belanja', icon: FontAwesomeIcons.shoppingBag, color: Colors.blue),
    Category(id: 'cat_makan', name: 'Makan & Minum', icon: FontAwesomeIcons.utensils, color: Colors.orange),
    Category(id: 'cat_transportasi', name: 'Transportasi', icon: FontAwesomeIcons.car, color: Colors.red),
    Category(id: 'cat_hiburan', name: 'Hiburan', icon: FontAwesomeIcons.gamepad, color: Colors.purple),
    Category(id: 'cat_tagihan', name: 'Tagihan', icon: FontAwesomeIcons.fileInvoiceDollar, color: Colors.brown),
    Category(id: 'cat_lain_lain_pengeluaran', name: 'Lain-lain', icon: FontAwesomeIcons.ellipsisH, color: Colors.grey),
  ];

  final List<Category> _incomeCategories = [
    Category(id: 'cat_gaji', name: 'Gaji', icon: FontAwesomeIcons.wallet, color: Colors.green),
    Category(id: 'cat_investasi', name: 'Investasi', icon: FontAwesomeIcons.chartLine, color: Colors.teal),
    Category(id: 'cat_hadiah', name: 'Hadiah', icon: FontAwesomeIcons.gift, color: Colors.pink),
    Category(id: 'cat_lain_lain_pemasukan', name: 'Lain-lain', icon: FontAwesomeIcons.ellipsisH, color: Colors.grey),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      // Inisialisasi dari transaksi yang akan diedit
      final t = widget.transactionToEdit!;
      _selectedType = t.type;
      _amountController.text = t.amount.toStringAsFixed(0); // Tanpa desimal
      _titleController.text = t.title;
      _noteController.text = t.note ?? '';
      _selectedDate = t.date;

      // Inisialisasi kategori/akun berdasarkan tipe
      if (t.type == mymodel.TransactionType.income || t.type == mymodel.TransactionType.expense) {
        _selectedCategory = t.categoryId;
        _selectedFromAccount = t.fromAccount;
      } else if (t.type == mymodel.TransactionType.transfer) {
        _selectedFromAccount = t.fromAccount;
        _selectedToAccount = t.toAccount;
      }
    } else {
      // Set default account for new record
      if (_dummyAccounts.isNotEmpty) {
        _selectedFromAccount = _dummyAccounts.first;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.yellow, // Warna header tanggal
              onPrimary: Colors.black, // Warna teks di header tanggal
              onSurface: Colors.white, // Warna teks di kalender
              surface: Color(0xFF1C1C1C), // Warna background kalender
            ),
            dialogBackgroundColor: const Color(0xFF1C1C1C),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk menyimpan transaksi
  Future<void> _saveTransaction() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (userProvider.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda harus login untuk menyimpan transaksi.'), backgroundColor: Colors.red),
        );
        return;
      }

      final userId = userProvider.currentUser!.uid;
      final amount = double.parse(_amountController.text);
      final title = _titleController.text;
      final note = _noteController.text.isEmpty ? null : _noteController.text;

      // Dapatkan objek Category lengkap
      Category? selectedCategoryObject;
      if (_selectedType == mymodel.TransactionType.expense) {
        selectedCategoryObject = _expenseCategories.firstWhere(
            (cat) => cat.id == _selectedCategory,
            orElse: () => _expenseCategories.first // Default jika tidak ditemukan (error case)
        );
      } else if (_selectedType == mymodel.TransactionType.income) {
        selectedCategoryObject = _incomeCategories.firstWhere(
            (cat) => cat.id == _selectedCategory,
            orElse: () => _incomeCategories.first // Default jika tidak ditemukan (error case)
        );
      }

      mymodel.Transaction newTransaction;

      if (widget.transactionToEdit != null) {
        // Mode Edit
        newTransaction = widget.transactionToEdit!.copyWith(
          amount: amount,
          title: title,
          note: note,
          date: _selectedDate,
          type: _selectedType,
          categoryId: _selectedCategory,
          categoryName: selectedCategoryObject?.name,
          categoryIcon: selectedCategoryObject?.icon,
          categoryColor: selectedCategoryObject?.color,
          fromAccount: _selectedFromAccount,
          toAccount: _selectedType == mymodel.TransactionType.transfer ? _selectedToAccount : null,
          userId: userId, // Pastikan userId tidak berubah saat edit
        );
        await transactionProvider.updateTransaction(newTransaction);
      } else {
        // Mode Tambah Baru
        newTransaction = mymodel.Transaction(
          id: const Uuid().v4(),
          userId: userId,
          amount: amount,
          title: title,
          note: note,
          date: _selectedDate,
          type: _selectedType,
          categoryId: _selectedCategory,
          categoryName: selectedCategoryObject?.name,
          categoryIcon: selectedCategoryObject?.icon,
          categoryColor: selectedCategoryObject?.color,
          fromAccount: _selectedFromAccount,
          toAccount: _selectedType == mymodel.TransactionType.transfer ? _selectedToAccount : null,
          createdAt: DateTime.now(),
        );
        await transactionProvider.addTransaction(newTransaction);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.transactionToEdit == null
              ? 'Transaksi berhasil ditambahkan!'
              : 'Transaksi berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Kembali ke halaman sebelumnya dan beri sinyal sukses
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk UserProvider di sini jika Anda ingin menampilkan
    // sesuatu terkait user di halaman ini, tapi untuk userId, Provider.of(listen: false) sudah cukup.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transactionToEdit == null ? 'Tambah Rekaman Baru' : 'Edit Rekaman',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Pemilihan Tipe Transaksi (Pemasukan/Pengeluaran/Transfer)
            _buildTypeSelection(),
            const SizedBox(height: 20),

            // Input Jumlah
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Hanya angka dan desimal (maks 2)
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Jumlah harus angka positif';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Input Judul/Nama Transaksi
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Judul Transaksi', Icons.text_fields),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Pemilihan Tanggal
            _buildDateSelection(),
            const SizedBox(height: 20),

            // Input Kategori (Hanya untuk Pemasukan/Pengeluaran)
            if (_selectedType != mymodel.TransactionType.transfer)
              _buildCategoryDropdown(),
            if (_selectedType != mymodel.TransactionType.transfer)
              const SizedBox(height: 20),

            // Pemilihan Akun Asal
            _buildAccountDropdown('Dari Akun', _selectedFromAccount, (String? newValue) {
              setState(() {
                _selectedFromAccount = newValue;
              });
            }, _dummyAccounts),
            const SizedBox(height: 20),

            // Pemilihan Akun Tujuan (Hanya untuk Transfer)
            if (_selectedType == mymodel.TransactionType.transfer)
              _buildAccountDropdown('Ke Akun', _selectedToAccount, (String? newValue) {
                setState(() {
                  _selectedToAccount = newValue;
                });
              }, _dummyAccounts.where((acc) => acc != _selectedFromAccount).toList()),
            if (_selectedType == mymodel.TransactionType.transfer)
              const SizedBox(height: 20),

            // Input Catatan (Opsional)
            TextFormField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Catatan (Opsional)', Icons.description),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                widget.transactionToEdit == null ? 'Simpan' : 'Perbarui',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Dekorasi Input
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.yellow),
      filled: true,
      fillColor: const Color(0xFF1C1C1C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Helper: Pemilihan Tipe Transaksi (Pemasukan/Pengeluaran/Transfer)
  Widget _buildTypeSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(mymodel.TransactionType.income, 'Pemasukan', Colors.green),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTypeButton(mymodel.TransactionType.expense, 'Pengeluaran', Colors.red),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTypeButton(mymodel.TransactionType.transfer, 'Transfer', Colors.yellow),
        ),
      ],
    );
  }

  Widget _buildTypeButton(mymodel.TransactionType type, String label, Color color) {
    final bool isSelected = _selectedType == type;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedType = type;
          // Reset kategori/akun tujuan saat tipe berubah
          _selectedCategory = null;
          if (type != mymodel.TransactionType.transfer && _selectedFromAccount == _selectedToAccount) {
            _selectedToAccount = null; // Reset jika akun sama pada transfer
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : const Color(0xFF1C1C1C),
        foregroundColor: isSelected ? Colors.black : Colors.white,
        side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey[800]!),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }

  // Helper: Pemilihan Tanggal
  Widget _buildDateSelection() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: _inputDecoration('Tanggal', Icons.calendar_today),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.yellow),
          ],
        ),
      ),
    );
  }

  // Helper: Dropdown Kategori
  Widget _buildCategoryDropdown() {
    List<Category> categories = _selectedType == mymodel.TransactionType.income
        ? _incomeCategories
        : _expenseCategories;

    // Set default category jika belum ada atau jika tipe berubah
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first.id;
    } else if (_selectedCategory != null && !categories.any((cat) => cat.id == _selectedCategory)) {
      // Jika kategori yang dipilih sebelumnya tidak ada di daftar kategori saat ini
      _selectedCategory = categories.first.id;
    }


    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: categories.map((Category category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            children: [
              Icon(category.icon, color: category.color, size: 20),
              const SizedBox(width: 10),
              Text(category.name, style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      decoration: _inputDecoration('Kategori', Icons.category),
      dropdownColor: const Color(0xFF1C1C1C),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih kategori';
        }
        return null;
      },
    );
  }

  // Helper: Dropdown Akun
  Widget _buildAccountDropdown(String label, String? currentValue,
      ValueChanged<String?> onChanged, List<String> accountList) {

    // Set default account jika belum ada atau jika list akun kosong
    if (currentValue == null && accountList.isNotEmpty) {
      // Pilih akun pertama sebagai default
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged(accountList.first);
      });
    } else if (currentValue != null && !accountList.contains(currentValue)) {
      // Jika akun yang dipilih sebelumnya tidak ada di daftar akun saat ini
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChanged(accountList.first);
      });
    }


    return DropdownButtonFormField<String>(
      value: currentValue,
      items: accountList.map((String account) {
        return DropdownMenuItem<String>(
          value: account,
          child: Text(account, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: _inputDecoration(label, Icons.account_balance_wallet),
      dropdownColor: const Color(0xFF1C1C1C),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih akun';
        }
        if (_selectedType == mymodel.TransactionType.transfer &&
            _selectedFromAccount == _selectedToAccount &&
            _selectedFromAccount != null) { // Jika transfer dan akun asal & tujuan sama
              return 'Akun asal dan tujuan tidak boleh sama.';
        }
        return null;
      },
    );
  }
}