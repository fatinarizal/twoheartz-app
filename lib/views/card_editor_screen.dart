import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CardEditorScreen extends StatefulWidget {
  const CardEditorScreen({super.key});

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends State<CardEditorScreen> {
  final GlobalKey _canvasKey = GlobalKey();

  // Canvas State Variables
  String _groomName = 'Groom';
  String _brideName = 'Bride';
  String _location = 'Wedding Venue';
  String _selectedTemplate = 'Floral Romantic';

  // Draggable Offsets
  Offset _titleOffset = const Offset(100, 40);
  Offset _namesOffset = const Offset(70, 100);
  Offset _locationOffset = const Offset(60, 180);

  // Styling options
  Color _textColor = const Color(0xFFE91E63);
  double _fontSize = 24.0;

  // Background Templates
  BoxDecoration _getTemplateDecoration() {
    switch (_selectedTemplate) {
      case 'Minimalist Gold':
        return BoxDecoration(
          color: const Color(0xFFFFFDF8),
          border: Border.all(color: const Color(0xFFD4AF37), width: 3),
          borderRadius: BorderRadius.circular(16),
        );
      case 'Purple Black':
        return BoxDecoration(
          color: const Color(0xFF1F1A24),
          borderRadius: BorderRadius.circular(16),
        );
      case 'Floral Romantic':
      default:
        return BoxDecoration(
          color: const Color(0xFFFFF0F5),
          border: Border.all(color: const Color(0xFFF8BBD0), width: 2),
          borderRadius: BorderRadius.circular(16),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canva Card Studio'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Toolbar: Template & Style Selectors
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Template: '),
                  DropdownButton<String>(
                    value: _selectedTemplate,
                    items: ['Floral Romantic', 'Minimalist Gold', 'Purple Black']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTemplate = val);
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.format_size),
                    onPressed: () => setState(() => _fontSize = _fontSize == 24.0 ? 30.0 : 24.0),
                    tooltip: 'Toggle Font Size',
                  ),
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () {
                      setState(() {
                        _textColor = _textColor == const Color(0xFFE91E63)
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFFE91E63);
                      });
                    },
                    tooltip: 'Toggle Main Color',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Canva-style Interactive Canvas
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _canvasKey,
                child: Container(
                  width: 340,
                  height: 480,
                  decoration: _getTemplateDecoration(),
                  child: Stack(
                    children: [
                      // Layer 1: Title Header (Draggable)
                      Positioned(
                        left: _titleOffset.dx,
                        top: _titleOffset.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _titleOffset += details.delta;
                            });
                          },
                          child: Text(
                            'THE WEDDING OF',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: _textColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),

                      // Layer 2: Couple Names (Draggable)
                      Positioned(
                        left: _namesOffset.dx,
                        top: _namesOffset.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _namesOffset += details.delta;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12, style: BorderStyle.none),
                            ),
                            child: Text(
                              '$_groomName & $_brideName',
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.bold,
                                color: _textColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Layer 3: Location Pin (Draggable)
                      Positioned(
                        left: _locationOffset.dx,
                        top: _locationOffset.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _locationOffset += details.delta;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on, size: 18, color: _textColor),
                              const SizedBox(width: 4),
                              Text(
                                _location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedTemplate == 'Purple Black' ? Colors.white70 : Colors.black87,
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
          ),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '💡 Drag any element inside the card canvas to customize layout',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}