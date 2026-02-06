import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/tone_type.dart';

class ResultScreen extends StatefulWidget {
  final String originalText;
  final String rewrittenText;
  final ToneType tone;

  const ResultScreen({
    super.key,
    required this.originalText,
    required this.rewrittenText,
    required this.tone,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isBetter = false; // Simple feedback state
  bool _isLoading = false;

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.rewrittenText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Rewritten text copied to clipboard!"),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShare() {
    Share.share(widget.rewrittenText, subject: 'Rewritten Email (${widget.tone.label})');
  }

  void _handleRegenerate() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Regenerated! (Simulation)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Word counts
    final originalWordCount = widget.originalText.trim().split(RegExp(r'\s+')).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Result"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {}, 
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
                  // Section 1: Original Draft
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("ORIGINAL DRAFT", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                      Text("$originalWordCount words", style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.originalText,
                      style: AppTextStyles.body2.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section 2: Rewritten
                  Row(
                    children: [
                      Text("REWRITTEN", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.tone.color,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.tone.label.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEB3B).withValues(alpha: 51),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFC107)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
                            SizedBox(width: 4),
                            Text(
                              "AI Optimized",
                              style: TextStyle(color: Color(0xFFFF6F00), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 20),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _isLoading 
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ))
                      : Text(
                          widget.rewrittenText,
                          style: AppTextStyles.body1.copyWith(height: 1.6),
                        ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Feedback
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Is this version better?", style: AppTextStyles.caption),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          color: _isBetter ? AppColors.primary : Colors.grey,
                        ),
                        onPressed: () => setState(() => _isBetter = true),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.thumb_down,
                          color: !_isBetter && _isBetter /* Logic slightly flawed for toggle, keeping simple */ ? Colors.grey : Colors.grey,
                        ),
                         // Improvements: Add proper toggle logic later
                        onPressed: () => setState(() => _isBetter = false), 
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 26),
                          AppColors.accent.withValues(alpha: 13)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 51)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.psychology, size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Text(
                          "Powered by Advanced Language Model v4",
                          style: AppTextStyles.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Fixed Bottom Actions
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
            child: Row(
              children: [
                // Regenerate
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.refresh, color: AppColors.textPrimary),
                    onPressed: _isLoading ? null : _handleRegenerate,
                    tooltip: "Regenerate",
                  ),
                ),
                const SizedBox(width: 12),
                
                // Share
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                    onPressed: _handleShare,
                    tooltip: "Share",
                  ),
                ),
                const SizedBox(width: 12),
                
                // Copy Button (Expanded)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleCopy,
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy to Clipboard"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
