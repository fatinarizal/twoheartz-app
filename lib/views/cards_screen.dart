import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/database_service.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _dbService = SupabaseDatabaseService();
  final _formKey = GlobalKey<FormState>();

  final _brideController = TextEditingController();
  final _groomController = TextEditingController();
  final _locationController = TextEditingController();
  final _songUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedTheme = 'Modern Classic';
  String? _existingCardId;
  bool _isLoading = false;

  void _populateForm(CardModel card) {
    _existingCardId = card.id;
    _brideController.text = card.brideName;
    _groomController.text = card.groomName;
    _locationController.text = card.location;
    _songUrlController.text = card.songUrl ?? '';
    _descriptionController.text = card.description ?? '';
    _selectedTheme = card.designTheme;
  }

  Future<void> _saveCardDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final card = CardModel(
        id: _existingCardId ?? '',
        weddingId: '',
        brideName: _brideController.text.trim(),
        groomName: _groomController.text.trim(),
        location: _locationController.text.trim(),
        songUrl: _songUrlController.text.trim().isEmpty ? null : _songUrlController.text.trim(),
        designTheme: _selectedTheme,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      );

      await _dbService.saveCard(card);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wedding card saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateWhatsAppMessage(CardModel card) {
    return '''
💍 *WEDDING INVITATION* 💍

Together with their families,
*${card.groomName}* & *${card.brideName}*

Joyfully invite you to celebrate their wedding!

📍 *Location:* ${card.location}
${card.description != null && card.description!.isNotEmpty ? '\n📝 *Note:* ${card.description}' : ''}
${card.songUrl != null && card.songUrl!.isNotEmpty ? '\n🎵 *Our Song:* ${card.songUrl}' : ''}

We look forward to celebrating with you! ✨
''';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CardModel>>(
      stream: _dbService.getCardsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final card = snapshot.data!.first;
          if (_existingCardId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateForm(card);
            });
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Digital Card Generator',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Form Section
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _groomController,
                            decoration: const InputDecoration(labelText: 'Groom Name'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _brideController,
                            decoration: const InputDecoration(labelText: 'Bride Name'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Venue / Location'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _songUrlController,
                      decoration: const InputDecoration(labelText: 'Song URL (Optional)'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTheme,
                      decoration: const InputDecoration(labelText: 'Design Theme'),
                      items: ['Modern Classic', 'Floral Romantic', 'Minimalist Gold', 'Rustic Elegance']
                          .map((theme) => DropdownMenuItem(value: theme, child: Text(theme)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTheme = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Additional Message / Note'),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveCardDetails,
                      icon: const Icon(Icons.save),
                      label: Text(_isLoading ? 'Saving...' : 'Save Card Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(45),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 40),

              // Live Preview Section
              const Text(
                'Live Preview & Share',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: const Color(0xFFFFF0F5),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        _selectedTheme.toUpperCase(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], letterSpacing: 2),
                      ),
                      const SizedBox(height: 12),
                      const Icon(Icons.favorite, color: Color(0xFFE91E63), size: 36),
                      const SizedBox(height: 12),
                      Text(
                        '${_groomController.text.isEmpty ? "Groom" : _groomController.text} & ${_brideController.text.isEmpty ? "Bride" : _brideController.text}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _locationController.text.isEmpty ? "Wedding Venue" : _locationController.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      if (_descriptionController.text.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _descriptionController.text,
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          final currentCard = CardModel(
                            id: '',
                            weddingId: '',
                            brideName: _brideController.text,
                            groomName: _groomController.text,
                            location: _locationController.text,
                            songUrl: _songUrlController.text,
                            designTheme: _selectedTheme,
                            description: _descriptionController.text,
                          );
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Generated Invitation Message'),
                              content: SelectableText(_generateWhatsAppMessage(currentCard)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Generate Shareable Invitation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}