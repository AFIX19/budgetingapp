import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; 
import 'package:provider/provider.dart';
import '../../../data/models/transaction.dart' as mymodel;
import '../../../providers/transaction_provider.dart';
import '../../../providers/user_provider.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import '../../../data/models/category.dart';

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
  String? _selectedCategory;
  String? _selectedFromAccount; 
  String? _selectedToAccount; 

  final List<String> _dummyAccounts = ['Cash', 'Bank Account', 'E-Wallet'];

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
      final t = widget.transactionToEdit!;
      _selectedType = t.type;
      _amountController.text = t.amount.toStringAsFixed(0);
      _titleController.text = t.title;
      _noteController.text = t.note ?? '';
      _selectedDate = t.date;

      if (t.type == mymodel.TransactionType.income || t.type == mymodel.TransactionType.expense) {
        _selectedCategory = t.categoryId;
        _selectedFromAccount = t.fromAccount;
      } else if (t.type == mymodel.TransactionType.transfer) {
        _selectedFromAccount = t.fromAccount;
        _selectedToAccount = t.toAccount;
      }
    } else {
        if (_dummyAccounts.isNotEmpty) {
        _selectedFromAccount = _dummyAccounts.first;
      }
      // Set default category for new transaction
      if (_selectedType == mymodel.TransactionType.expense && _expenseCategories.isNotEmpty) {
        _selectedCategory = _expenseCategories.first.id;
      } else if (_selectedType == mymodel.TransactionType.income && _incomeCategories.isNotEmpty) {
        _selectedCategory = _incomeCategories.first.id;
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
              primary: Colors.yellow, // warna untuk header tanggal
              onPrimary: Colors.black, // warna teks untuk header tanggal
              onSurface: Colors.white, // warna teks untuk kalender
              surface: Color(0xFF1C1C1C), // warna untuk background kalender
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

  // fungsi untuk menyimpan transaksi
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

      // untuk mendapatkan objek category lengkap
      Category? selectedCategoryObject;
      if (_selectedType == mymodel.TransactionType.expense) {
        selectedCategoryObject = _expenseCategories.firstWhere(
            (cat) => cat.id == _selectedCategory,
            orElse: () => _expenseCategories.first // hanya untuk default saja jika tidak ditemukan "error case"
        );
      } else if (_selectedType == mymodel.TransactionType.income) {
        selectedCategoryObject = _incomeCategories.firstWhere(
            (cat) => cat.id == _selectedCategory,
            orElse: () => _incomeCategories.first // hanya untuk default saja jika tidak ditemukan "error case"
        );
      }

      mymodel.Transaction newTransaction;

      if (widget.transactionToEdit != null) {
        // untuk edit
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
          userId: userId, 
        );
        await transactionProvider.updateTransaction(newTransaction);
      } else {
        // untuk mode tambah baru
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
      Navigator.of(context).pop(true); // untuk kembali ke halaman sebelumnya dan memberi sinyal sukses 
    }
  }

  void _onTypeChanged(mymodel.TransactionType newType) {
    setState(() {
      _selectedType = newType;
      // Reset category and set a default when type changes
      _selectedCategory = null;
      if (newType == mymodel.TransactionType.income && _incomeCategories.isNotEmpty) {
        _selectedCategory = _incomeCategories.first.id;
      } else if (newType == mymodel.TransactionType.expense && _expenseCategories.isNotEmpty) {
        _selectedCategory = _expenseCategories.first.id;
      }

      // Reset 'To Account' if it's not a transfer
      if (newType != mymodel.TransactionType.transfer) {
        _selectedToAccount = null;
      } else if (_selectedFromAccount == _selectedToAccount) {
        // Ensure 'To Account' is not the same as 'From Account' for a new transfer
        _selectedToAccount = _dummyAccounts.where((acc) => acc != _selectedFromAccount).firstOrNull;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transactionToEdit == null ? 'Tambah Catatan Baru' : 'Edit Catatan',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // untuk memilih tipe transaksi untuk (pemasukan/pengeluaran/transfer)
            _buildTypeSelection(),
            const SizedBox(height: 20),
            // untuk menginput jumlah
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // hanya untuk angka dan desimal saja dan max: 2 saja
              ],
              //untuk validator ketika tambah jumlah 
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

            // untuk input judul
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
              labelText: 'Judul Transaksi',
              labelStyle: TextStyle(color: Colors.grey[400]!, ),
               ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // memilih tanggal
            _buildDateSelection(),
            const SizedBox(height: 20),

            // input kategori (hanya untuk pemasukan/pengeluaran)
            if (_selectedType != mymodel.TransactionType.transfer)
              _buildCategoryDropdown(),
            if (_selectedType != mymodel.TransactionType.transfer)
              const SizedBox(height: 20),

            // pemilihan akun asal
            _buildAccountDropdown('Dari Akun', _selectedFromAccount, (String? newValue) {
              setState(() {
                _selectedFromAccount = newValue;
              });
            }, _dummyAccounts),
            const SizedBox(height: 20),

            // pemilihan akun tujuan (hanya untuk transfer)
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
              decoration: _inputDecoration('Catatan (Opsional)', Icons.description, color: Colors.grey[400]!),
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

  InputDecoration _inputDecoration(String label, IconData icon, {required Color color}) {
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
      onPressed: () => _onTypeChanged(type),
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

  Widget _buildDateSelection() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText:'Tanggal', 
          labelStyle: TextStyle(color: Colors.grey[400]!),
          ),
      
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


  Widget _buildCategoryDropdown() {
    List<Category> categories = _selectedType == mymodel.TransactionType.income
        ? _incomeCategories
        : _expenseCategories;
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
      decoration: _inputDecoration('Kategori', Icons.category, color: Colors.grey[400]!),
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

  Widget _buildAccountDropdown(String label, String? currentValue,
      ValueChanged<String?> onChanged, List<String> accountList) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      items: accountList.map((String account) {
        return DropdownMenuItem<String>(
          value: account,
          child: Text(account, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]!),
        prefixIcon: Icon (Icons.account_balance_wallet, color:Colors.yellow),
        ),
      dropdownColor: const Color(0xFF1C1C1C),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Pilih akun';
        }
        if (_selectedType == mymodel.TransactionType.transfer &&
            _selectedFromAccount == _selectedToAccount &&
            _selectedFromAccount != null) {
              return 'Akun asal dan tujuan tidak boleh sama.';
        }
        return null;
      },
    );
  }
}