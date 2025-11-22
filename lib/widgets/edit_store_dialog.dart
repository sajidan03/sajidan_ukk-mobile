import 'package:flutter/material.dart';
import 'package:skillpp_kelas12/models/store_model.dart';
import 'package:skillpp_kelas12/services/store_service.dart';

class EditStoreDialog extends StatefulWidget {
  final Store store;
  final Function() onStoreUpdated;

  const EditStoreDialog({
    Key? key,
    required this.store,
    required this.onStoreUpdated,
  }) : super(key: key);

  @override
  State<EditStoreDialog> createState() => _EditStoreDialogState();
}

class _EditStoreDialogState extends State<EditStoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaTokoController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kontakTokoController = TextEditingController();
  final _alamatController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _namaTokoController.text = widget.store.namaToko;
    _deskripsiController.text = widget.store.deskripsi;
    _kontakTokoController.text = widget.store.kontakToko;
    _alamatController.text = widget.store.alamat;
  }

  Future<void> _updateStore() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await StoreService.updateStore(
          namaToko: _namaTokoController.text.trim(),
          deskripsi: _deskripsiController.text.trim(),
          kontakToko: _kontakTokoController.text.trim(),
          alamat: _alamatController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Toko berhasil diupdate'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onStoreUpdated();
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal update toko: ${result['message']}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _deskripsiController.dispose();
    _kontakTokoController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.store, color: Colors.blue),
          SizedBox(width: 8),
          Text('Edit Toko'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nama Toko
              TextFormField(
                controller: _namaTokoController,
                decoration: InputDecoration(
                  labelText: 'Nama Toko',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama toko tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Toko',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Kontak
              TextFormField(
                controller: _kontakTokoController,
                decoration: InputDecoration(
                  labelText: 'Kontak Toko',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                hintText: '081234567890',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kontak toko tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Alamat
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat Toko',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateStore,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Simpan'),
        ),
      ],
    );
  }
}