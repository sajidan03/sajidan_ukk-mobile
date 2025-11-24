import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:skillpp_kelas12/models/products_model.dart';
import 'package:skillpp_kelas12/services/store_service.dart'; // Import StoreService

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final Function(Product, List<String>) onSave;

  const ProductFormDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  
  int _selectedKategori = 1;
  final List<String> _selectedImages = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;
  String _categoriesError = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.product != null) {
      _namaController.text = widget.product!.namaProduk;
      _hargaController.text = widget.product!.intHarga.toString();
      _stokController.text = widget.product!.intStok.toString();
      _deskripsiController.text = widget.product!.deskripsi;
      _selectedKategori = widget.product!.intIdKategori;
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = '';
    });

    final result = await StoreService.getCategories();

    setState(() {
      _isLoadingCategories = false;
      
      if (result['success'] == true) {
        // Data langsung dari API response
        _categories = (result['data'] as List).cast<Map<String, dynamic>>();
        
        print('Loaded ${_categories.length} categories');
        
        // Set default selected category
        if (_categories.isNotEmpty) {
          if (widget.product == null) {
            // For new product, select first category
            _selectedKategori = _categories.first['id_kategori'];
          } else {
            // For editing, ensure the product's category exists in the list
            final productCategoryExists = _categories.any(
              (cat) => cat['id_kategori'] == widget.product!.intIdKategori
            );
            if (!productCategoryExists && _categories.isNotEmpty) {
              _selectedKategori = _categories.first['id_kategori'];
            }
          }
        }
      } else {
        _categoriesError = result['message'] ?? 'Gagal memuat kategori';
        // Fallback categories
        // _categories = [
        //   {'id_kategori': 1, 'nama_kategori': 'Elektronik'},
        //   {'id_kategori': 2, 'nama_kategori': 'Buku'},
        //   {'id_kategori': 3, 'nama_kategori': 'Seragam'},
        //   {'id_kategori': 4, 'nama_kategori': 'ATK'},
        //   {'id_kategori': 5, 'nama_kategori': 'Aksesoris'},
        // ];
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menggunakan kategori default'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
            result.files.map((file) => file.path ?? file.name).toList()
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} gambar dipilih'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildImagePreview(String imagePath) {
    if (imagePath.startsWith('/') || imagePath.contains(':\\')) {
      try {
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo, color: Colors.grey[400], size: 30),
          SizedBox(height: 4),
          Text(
            'Preview',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = widget.product != null
          ? widget.product!.copyWith(
              idKategori: _selectedKategori,
              namaProduk: _namaController.text,
              harga: int.tryParse(_hargaController.text) ?? 0,
              stok: int.tryParse(_stokController.text) ?? 0,
              deskripsi: _deskripsiController.text,
            )
          : Product.createNew(
              idKategori: _selectedKategori,
              namaProduk: _namaController.text,
              harga: int.tryParse(_hargaController.text) ?? 0,
              stok: int.tryParse(_stokController.text) ?? 0,
              deskripsi: _deskripsiController.text,
            );

      widget.onSave(product, _selectedImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product != null ? 'Edit Produk' : 'Tambah Produk'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kategori Dropdown
              _isLoadingCategories
                  ? Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircularProgressIndicator(strokeWidth: 2),
                          SizedBox(width: 12),
                          Text('Memuat kategori...'),
                        ],
                      ),
                    )
                  : _categoriesError.isNotEmpty
                      ? Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _categoriesError,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      : DropdownButtonFormField<int>(
                          value: _selectedKategori,
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _categories.map((category) {
                            final categoryId = category['id_kategori'] as int;
                            final categoryName = category['nama_kategori'] as String;
                            
                            return DropdownMenuItem<int>(
                              value: categoryId,
                              child: Text(categoryName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKategori = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null) return 'Pilih kategori';
                            return null;
                          },
                        ),
              SizedBox(height: 16),

              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk harus diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _hargaController,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Harga harus angka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _stokController,
                decoration: InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Stok harus angka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi harus diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gambar Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: Icon(Icons.photo_library),
                    label: Text('Pilih Gambar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  
                  if (_selectedImages.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text('Gambar terpilih (${_selectedImages.length}):'),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: _buildImagePreview(_selectedImages[index]),
                              ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red, size: 20),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          child: Text(widget.product != null ? 'Update' : 'Simpan'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }
}