import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../models/tone_type.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../widgets/tone_chip.dart';
import 'result_screen.dart'; 

class RewriteInputScreen extends StatefulWidget {
  const RewriteInputScreen({super.key});

  @override
  State<RewriteInputScreen> createState() => _RewriteInputScreenState();
}

class _RewriteInputScreenState extends State<RewriteInputScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController _textController = TextEditingController();
  ToneType _selectedTone = ToneType.professional;
  int _wordCount = 0;
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  String _lastTranscript = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateWordCount);
    _initSpeech();
  }

  @override
  void dispose() {
    _speech.stop();
    _textController.removeListener(_updateWordCount);
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice input failed. Please try again.')),
        );
      },
    );
    if (mounted) {
      setState(() => _speechAvailable = available);
    }
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition is not available on this device.')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    _lastTranscript = '';
    final started = await _speech.listen(
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
      ),
      onResult: (result) {
        if (!result.finalResult) return;
        final transcript = result.recognizedWords.trim();
        if (transcript.isEmpty || transcript == _lastTranscript) return;
        _lastTranscript = transcript;
        final current = _textController.text.trimRight();
        final next = current.isEmpty ? transcript : '$current $transcript';
        _textController.text = next;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      },
    );

    if (mounted) {
      setState(() => _isListening = started);
    }
  }

  void _updateWordCount() {
    setState(() {
      _wordCount = _textController.text.trim().isEmpty 
          ? 0 
          : _textController.text.trim().split(RegExp(r'\s+')).length;
    });
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    _textController.clear();
    setState(() {
      _selectedTone = ToneType.professional;
    });
  }

  String _extractSubject(String text) {
    final lines = text.trim().split(RegExp(r'\r?\n'));
    if (lines.isNotEmpty && lines.first.trim().toLowerCase().startsWith('subject:')) {
      String explicit = lines.first.trim().substring('subject:'.length).trim();
      if (explicit.isNotEmpty) {
        if (explicit.length > 40) {
          explicit = explicit.substring(0, 40).trim();
        }
        return _sentenceCase(explicit);
      }
    }
    final core = _rewriteCoreMessage(text);
    if (core.isEmpty) return 'Message';
    final words = core.replaceAll(RegExp(r'[.!?]$'), '').split(' ');
    final take = words.length > 6 ? 6 : words.length;
    final subject = words.take(take).join(' ').trim();
    return _sentenceCase(subject.isEmpty ? 'Message' : subject);
  }

  String _stripSubjectLine(String text) {
    final lines = text.trim().split(RegExp(r'\r?\n'));
    if (lines.isNotEmpty && lines.first.trim().toLowerCase().startsWith('subject:')) {
      return lines.skip(1).join('\n').trim();
    }
    return text.trim();
  }

  String _normalizeSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _ensurePeriod(String text) {
    if (text.isEmpty) return text;
    if (RegExp(r'[.!?]$').hasMatch(text)) return text;
    return '$text.';
  }

  String _sentenceCase(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  bool _containsWord(String text, String word) {
    return RegExp('\\b${RegExp.escape(word)}\\b', caseSensitive: false).hasMatch(text);
  }

  String _rewriteCoreMessage(String originalText) {
    String core = _stripSubjectLine(originalText);
    core = _normalizeSpaces(core);
    core = _sentenceCase(core);
    core = _ensurePeriod(core);
    return core;
  }

  String _buildLeaveMessage(String core, {required String tone}) {
    final durationMatch = RegExp(r'(\d+)\s*day', caseSensitive: false).firstMatch(core);
    final days = durationMatch?.group(1);
    final durationText = days != null ? ' for $days days' : '';
    if (tone == 'professional') {
      return 'I would like to respectfully request leave$durationText. I would be grateful if you could approve it. Please let me know if you need any additional information.';
    }
    if (tone == 'friendly') {
      return 'I wanted to ask for leave$durationText. I will be out during that time and will ensure my work is covered. Please let me know if you need anything else from me.';
    }
    if (tone == 'concise') {
      return 'Requesting leave$durationText. Please confirm.';
    }
    if (tone == 'urgent') {
      return 'I need leave$durationText and request your urgent approval.';
    }
    // assertive
    return 'I am requesting leave$durationText. Please confirm approval and next steps.';
  }

  String _cleanCore(String text) {
    String core = _rewriteCoreMessage(text);
    core = core.replaceAll(RegExp(r'^(please|kindly)\s+', caseSensitive: false), '');
    core = _sentenceCase(core);
    return core;
  }

  String _generateRewrittenText(String originalText, ToneType tone) {
    // Enhanced tone-based transformations with better rephrasing
    final subject = _extractSubject(originalText);
    final cleaned = _cleanCore(originalText);
    final hasLeave = _containsWord(cleaned, 'leave');
    final coreMessage = hasLeave
        ? _buildLeaveMessage(cleaned, tone: tone.name)
        : cleaned;
    String transformed = coreMessage;

    switch (tone) {
      case ToneType.professional:
        transformed =
            "Subject: $subject\n\nDear Sir/Madam,\n\nI am writing to inform you that $coreMessage. I appreciate your time and consideration.\n\nSincerely,\n[Your Name]";
        break;
      case ToneType.friendly:
        // Friendly and warm
        transformed =
            "Subject: $subject\n\nHi [Name],\n\nHope you're doing well. This is [Your Name]. $coreMessage\n\nLet me know what you think.\n\nBest,\n[Your Name]";
        break;
      case ToneType.concise:
        // Shorten and remove filler words
        transformed = "Subject: $subject\n\n$coreMessage";
        break;
      case ToneType.urgent:
        // Add urgency
        transformed =
            "Subject: Urgent: $subject\n\nThis is urgent. $coreMessage Please respond as soon as possible.";
        break;
      case ToneType.assertive:
        // Make it direct and firm
        transformed = "Subject: $subject\n\n$coreMessage Please confirm receipt and next steps.";
        break;
    }

    return transformed;
  }

  void _handleRewrite() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final text = _textController.text;

      // Simulate Loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Simulate AI Processing Delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context); // Close dialog

        // Generate dynamic rewritten text based on input and tone
        String rewritten = _generateRewrittenText(text, _selectedTone);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              originalText: text,
              rewrittenText: rewritten,
              tone: _selectedTone
            )
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Rewrite Email"),
        actions: [
          TextButton(
            onPressed: _handleClear,
            child: Text(
              "Clear",
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Input
                  Text("ORIGINAL EMAIL", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 13),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FormBuilder(
                      key: _formKey,
                      child: FormBuilderTextField(
                        name: 'email_input',
                        controller: _textController,
                        maxLines: null,
                        minLines: 10,
                        style: AppTextStyles.input,
                        decoration: InputDecoration(
                          hintText: "Paste, type, or use voice input...",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: IconButton(
                            tooltip: _isListening ? 'Stop recording' : 'Start voice input',
                            onPressed: _toggleListening,
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "$_wordCount / 2000 words",
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section 2: Tone Selection
                  Text("SELECT TONE", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ToneType.values.length,
                      itemBuilder: (context, index) {
                        final tone = ToneType.values[index];
                        return ToneChip(
                          tone: tone,
                          isSelected: _selectedTone == tone,
                          onTap: () {
                            setState(() {
                              _selectedTone = tone;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Spacing for bottom button
                ],
              ),
            ),
          ),
          
          // Fixed Bottom Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 13),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Container(
               decoration: BoxDecoration(
                  gradient: _wordCount > 0 ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ) : null,
                  color: _wordCount == 0 ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(16),
                ),
              child: ElevatedButton(
                onPressed: _wordCount > 0 ? _handleRewrite : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.grey,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_fix_high),
                    const SizedBox(width: 8),
                    Text("Rewrite with AI", style: AppTextStyles.button),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
