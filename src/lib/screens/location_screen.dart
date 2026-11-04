import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/services/prayer_service.dart';
import 'package:app/models/app_models.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitCustomLocation() {
    if (_formKey.currentState!.validate()) {
      final lat = double.parse(_latController.text.trim());
      final lng = double.parse(_lngController.text.trim());
      final name = _nameController.text.trim().isEmpty
          ? 'موقع مخصص'
          : _nameController.text.trim();

      final customCity = CityLocation(
        name: name,
        country: 'إحداثيات خاصة',
        latitude: lat,
        longitude: lng,
      );

      final service = Provider.of<PrayerService>(context, listen: false);
      service.updateLocation(customCity);

      _latController.clear();
      _lngController.clear();
      _nameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الموقع بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<PrayerService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الموقع والحساب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'الموقع الحالي المعتمد',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${service.currentLocation.name} (${service.currentLocation.country})',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'خط العرض: ${service.currentLocation.latitude} | خط الطول: ${service.currentLocation.longitude}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'طريقة حساب المواقيت',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CalculationMethod>(
                    value: service.method,
                    isExpanded: true,
                    onChanged: (method) {
                      if (method != null) {
                        service.setMethod(method);
                      }
                    },
                    items: CalculationMethod.all.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m.name),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'اختر من المدن الشهيرة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CityLocation.presets.map((city) {
                final isSelected = service.currentLocation.name == city.name;
                return ChoiceChip(
                  label: Text('${city.name} (${city.country})'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      service.updateLocation(city);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Text(
              'أو أدخل إحداثيات موقعك (Lat/Lng)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم المنطقة / المدينة (اختياري)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: const InputDecoration(
                          labelText: 'خط العرض (Latitude) مثل: 24.7136',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.my_location),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'يرجى إدخال خط العرض';
                          final numVal = double.tryParse(val);
                          if (numVal == null || numVal < -90 || numVal > 90) {
                            return 'أدخل رقم صحيح بين -90 و 90';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: const InputDecoration(
                          labelText: 'خط الطول (Longitude) مثل: 46.6753',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'يرجى إدخال خط الطول';
                          final numVal = double.tryParse(val);
                          if (numVal == null || numVal < -180 || numVal > 180) {
                            return 'أدخل رقم صحيح بين -180 و 180';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _submitCustomLocation,
                          icon: const Icon(Icons.save),
                          label: const Text('اعتماد الإحداثيات الجديدة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
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
}