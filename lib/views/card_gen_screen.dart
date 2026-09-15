import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class CardGenScreen extends StatefulWidget {
  const CardGenScreen({super.key});

  @override
  State<CardGenScreen> createState() => _CardGenScreenState();
}

class _CardGenScreenState extends State<CardGenScreen> {
  final _promptController = TextEditingController(
    text: 'purple gold theme, fatin and aminul, 23.04.2026, floral at taman tasik permaisuri #minulmitin',
  );
  final _mapsController = TextEditingController(
    text: 'https://maps.google.com/?q=Taman+Tasik+Permaisuri',
  );
  final _youtubeUrlController = TextEditingController(
    text: 'https://youtu.be/ukXC-cXF1rc?si=y1hbpGxaJ1Tvb0RZ',
  );

  final GlobalKey _cardBoundaryKey = GlobalKey();

  late YoutubePlayerController _ytController;

  bool _isLoading = false;
  bool _isFrontView = true;
  bool _isPlayingMusic = false;
  Map<String, dynamic>? _cardData;

  static const String _apiKey = 'YOUR_GEMINI_API_KEY';

  @override
  void initState() {
    super.initState();
    _initYoutubePlayer(_youtubeUrlController.text);
    _generateCardWithAI();
  }

  void _initYoutubePlayer(String url) {
    final videoId = YoutubePlayerController.convertUrlToId(url) ?? 'ukXC-cXF1rc';

    _ytController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
      ),
    );

    _ytController.stream.listen((event) {
      if (mounted) {
        setState(() {
          _isPlayingMusic = event.playerState == PlayerState.playing;
        });
      }
    });
  }

  void _setupYoutubePlayer(String url) {
    final videoId = YoutubePlayerController.convertUrlToId(url);
    if (videoId != null) {
      _ytController.loadVideoById(videoId: videoId);
    }
  }

  void _toggleYoutubeAudio() {
    if (_isPlayingMusic) {
      _ytController.pauseVideo();
    } else {
      _ytController.playVideo();
    }
  }

  @override
  void dispose() {
    _ytController.close();
    _promptController.dispose();
    _mapsController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _parseAnyUserPrompt(String prompt) {
    final lower = prompt.toLowerCase();

    // 1. Extract Bride & Groom Names
    String bride = "Bride";
    String groom = "Groom";
    final nameRegExp = RegExp(
      r'([a-zA-Z]+)\s*(?:and|&|dan|\+)\s*([a-zA-Z]+)',
      caseSensitive: false,
    );
    final nameMatch = nameRegExp.firstMatch(prompt);

    if (nameMatch != null) {
      final rawBride = nameMatch.group(1)!;
      final rawGroom = nameMatch.group(2)!;
      bride = rawBride[0].toUpperCase() + rawBride.substring(1).toLowerCase();
      groom = rawGroom[0].toUpperCase() + rawGroom.substring(1).toLowerCase();
    }

    // 2. Extract Date
    String dateStr = "SAVE THE DATE";
    final dateRegExp = RegExp(r'\b\d{1,2}[\.\/\-]\d{1,2}[\.\/\-]\d{2,4}\b');
    final dateMatch = dateRegExp.firstMatch(prompt);
    if (dateMatch != null) {
      dateStr = dateMatch.group(0)!;
    }

    // 3. Extract Hashtag
    String hashtagStr = "#${bride}X${groom}";
    final hashtagRegExp = RegExp(r'#\w+');
    final hashtagMatch = hashtagRegExp.firstMatch(prompt);
    if (hashtagMatch != null) {
      hashtagStr = hashtagMatch.group(0)!;
    }

    // 4. Extract Location / Venue (Text following 'at', 'in', or 'near')
    String venueStr = "WEDDING VENUE";
    final venueRegExp = RegExp(
      r'\b(?:at|in|near)\s+([^,#]+)',
      caseSensitive: false,
    );
    final venueMatch = venueRegExp.firstMatch(prompt);
    if (venueMatch != null) {
      venueStr = venueMatch.group(1)!.trim().toUpperCase();
    }

    // 5. Colors & Background Style Logic
    String bgHex = "#3B1443";
    String accentHex = "#D4AF37";
    String textHex = "#FFFFFF";

    if (lower.contains('white') || lower.contains('cream')) {
      bgHex = "#FAF5FC";
      textHex = "#3B1443";
    }

    return {
      "style": {
        "backgroundColorHex": bgHex,
        "borderColorHex": accentHex,
        "primaryTextColorHex": textHex,
        "accentColorHex": accentHex,
        "themeType": lower.contains('floral') ? "floral" : "modern"
      },
      "front": {
        "header": "WALIMATULURUS",
        "bride": bride,
        "groom": groom,
        "date": dateStr,
        "venue": venueStr,
        "hashtag": hashtagStr
      },
      "back": {
        "greeting": "السلام عليكم ورحمة الله وبركاته",
        "parents": "Keluarga $bride & Keluarga $groom",
        "speech": "Menjemput Tuan/Puan untuk menghadiri ke majlis Puteri dan Putera kami",
        "brideFull": bride,
        "groomFull": groom,
        "hijriDate": "5 SYAWAL 1447H",
        "time": "11:00 AM - 4:00 PM"
      }
    };
  }

  Future<void> _generateCardWithAI() async {
    final promptText = _promptController.text.trim();
    if (promptText.isEmpty) return;

    setState(() => _isLoading = true);

    if (_apiKey == 'YOUR_GEMINI_API_KEY' || _apiKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _cardData = _parseAnyUserPrompt(promptText);
        _isLoading = false;
      });
      return;
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      final systemInstruction = '''
        Return ONLY raw JSON:
        {
          "style": {"backgroundColorHex": "#FFFFFF", "borderColorHex": "#D4AF37", "primaryTextColorHex": "#1C2B1E", "accentColorHex": "#C59B27", "themeType": "floral"},
          "front": {"header": "WALIMATULURUS", "bride": "Bride", "groom": "Groom", "date": "Date", "venue": "Venue", "hashtag": "#Hashtag"},
          "back": {"greeting": "السلام عليكم ورحمة الله وبركاته", "parents": "Parents","speech":"Menjemput Tuan/Puan untuk menghadiri ke majlis Puteri dan Putera kami", "brideFull": "Bride", "groomFull": "Groom", "hijriDate": "Hijri Date", "time": "Time"}
        }
      ''';

      final response = await model.generateContent([
        Content.text('$systemInstruction\n\nPrompt: $promptText')
      ]);

      final rawText = response.text ?? '';
      final cleanedJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
      setState(() => _cardData = jsonDecode(cleanedJson));
    } catch (_) {
      setState(() => _cardData = _parseAnyUserPrompt(promptText));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadCard() async {
    try {
      final boundary = _cardBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card snapshot captured!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openUrl(String urlString) async {
    if (urlString.trim().isEmpty) return;
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _parseColor(String? hexString, Color defaultColor) {
    if (hexString == null) return defaultColor;
    try {
      final hex = hexString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _cardData?['style'];
    final front = _cardData?['front'];
    final back = _cardData?['back'];

    final themeType = style?['themeType'] ?? 'floral';
    final bgColor = _parseColor(style?['backgroundColorHex'], Colors.white);
    final borderColor = _parseColor(style?['borderColorHex'], const Color(0xFFD4AF37));
    final primaryColor = _parseColor(style?['primaryTextColorHex'], const Color(0xFF1C2B1E));
    final accentColor = _parseColor(style?['accentColorHex'], const Color(0xFFC59B27));

    return Scaffold(
      appBar: AppBar(title: const Text('AI Card Generator Studio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Prompt', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _mapsController,
              decoration: const InputDecoration(
                labelText: 'Google Maps Link',
                prefixIcon: Icon(Icons.location_on, color: Colors.redAccent),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _youtubeUrlController,
              onChanged: (url) => _setupYoutubePlayer(url),
              decoration: const InputDecoration(
                labelText: 'YouTube Music Link',
                prefixIcon: Icon(Icons.music_note, color: Colors.red),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateCardWithAI,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Updating Card...' : 'Generate Card with AI'),
              ),
            ),
            const SizedBox(height: 16),
            if (_cardData != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Front Card')),
                      ButtonSegment(value: false, label: Text('Back Card')),
                    ],
                    selected: {_isFrontView},
                    onSelectionChanged: (val) => setState(() => _isFrontView = val.first),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _downloadCard,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Save Card'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Center(
                child: RepaintBoundary(
                  key: _cardBoundaryKey,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 320,
                    height: 480,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: Stack(
                      children: [
                        // Hidden YouTube Web Player
                        SizedBox(
                          height: 1,
                          width: 1,
                          child: YoutubePlayer(
                            controller: _ytController,
                          ),
                        ),

                        if (themeType == 'floral')
                          Positioned.fill(
                            child: CustomPaint(
                              painter: FloralCornerPainter(color: accentColor),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor.withOpacity(0.7), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: _isFrontView
                                        ? [
                                      Icon(Icons.filter_vintage, color: accentColor, size: 24),
                                      const SizedBox(height: 4),
                                      Text(
                                        front?['header'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 10, letterSpacing: 2, color: accentColor, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        front?['bride'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 28, fontFamily: 'serif', color: primaryColor),
                                      ),
                                      Text('&', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: accentColor)),
                                      Text(
                                        front?['groom'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 28, fontFamily: 'serif', color: primaryColor),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.symmetric(horizontal: BorderSide(color: borderColor, width: 0.5)),
                                        ),
                                        child: Text(
                                          front?['date'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 9, letterSpacing: 1, color: primaryColor),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        front?['venue'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 9, color: primaryColor, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        front?['hashtag'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 9, color: accentColor),
                                      ),
                                    ]
                                        : [
                                      Text(
                                        back?['greeting'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: primaryColor),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        back?['parents'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: primaryColor),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        back?['speech'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: primaryColor),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${back?['brideFull']} & ${back?['groomFull']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        back?['hijriDate'] ?? '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 8, color: accentColor),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'MASA: ${back?['time']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 8, color: primaryColor),
                                      ),
                                      const SizedBox(height: 10),
                                      OutlinedButton.icon(
                                        onPressed: () => _openUrl(_mapsController.text),
                                        icon: const Icon(Icons.map, size: 14),
                                        label: const Text('Open Google Maps', style: TextStyle(fontSize: 9)),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: primaryColor,
                                          side: BorderSide(color: borderColor),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              // Play / Pause Toggle Button
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(
                                    _isPlayingMusic ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                    color: accentColor,
                                    size: 28,
                                  ),
                                  onPressed: _toggleYoutubeAudio,
                                  tooltip: _isPlayingMusic ? 'Pause Music' : 'Play Music',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class FloralCornerPainter extends CustomPainter {
  final Color color;
  FloralCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final pathTL = Path()..moveTo(8, 30)..quadraticBezierTo(8, 8, 30, 8);
    final pathTR = Path()..moveTo(size.width - 8, 30)..quadraticBezierTo(size.width - 8, 8, size.width - 30, 8);
    final pathBL = Path()..moveTo(8, size.height - 30)..quadraticBezierTo(8, size.height - 8, 30, size.height - 8);
    final pathBR = Path()..moveTo(size.width - 8, size.height - 30)..quadraticBezierTo(size.width - 8, size.height - 8, size.width - 30, size.height - 8);

    canvas.drawPath(pathTL, paint);
    canvas.drawPath(pathTR, paint);
    canvas.drawPath(pathBL, paint);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}