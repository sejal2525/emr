import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';

class OphthalmologyPredictionScreen extends StatefulWidget {
  const OphthalmologyPredictionScreen({Key? key}) : super(key: key);

  @override
  _OphthalmologyPredictionScreenState createState() => _OphthalmologyPredictionScreenState();
}

class _OphthalmologyPredictionScreenState extends State<OphthalmologyPredictionScreen> {
  final TextEditingController _iopController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cdrController = TextEditingController();

  bool _isLoading = false;
  String? _predictionResult;
  String? _riskLevel;
  double? _confidence;

  Future<void> _predictGlaucoma() async {
    // Validate inputs
    if (_iopController.text.isEmpty || _ageController.text.isEmpty || _cdrController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResult = null;
    });

    final url = Uri.parse('http://127.0.0.1:5000/predict_eye');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'IOP': double.parse(_iopController.text),
          'Age': double.parse(_ageController.text),
          'CDR': double.parse(_cdrController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictionResult = data['prediction'];
          _riskLevel = data['risk_level'];
          _confidence = data['confidence'];
        });
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getRiskColor() {
    if (_riskLevel == "High Risk") return Colors.redAccent;
    if (_riskLevel == "Moderate Risk") return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Glaucoma Diagnostic"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Decorative Orbs
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withOpacity(0.2),
                boxShadow: [BoxShadow(color: const Color(0xFF06B6D4).withOpacity(0.2), blurRadius: 80)],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.5, duration: 4.seconds),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD1FAE5).withOpacity(0.1),
                boxShadow: [BoxShadow(color: const Color(0xFFD1FAE5).withOpacity(0.1), blurRadius: 100)],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.2, duration: 5.seconds),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.visibility_rounded,
                    size: 64,
                    color: Color(0xFF06B6D4),
                  ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  const Text(
                    "Enter Patient Diagnostic Data",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  const Text(
                    "Our Logistic Regression model will analyze the features to predict Glaucoma risk.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  const SizedBox(height: 32),

                  // Input Cards
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _iopController,
                              label: "Intraocular Pressure (IOP)",
                              hint: "e.g., 22.5",
                              icon: Icons.compress,
                            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _ageController,
                              label: "Patient Age",
                              hint: "e.g., 65",
                              icon: Icons.person_outline,
                            ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _cdrController,
                              label: "Cup-to-Disc Ratio (CDR)",
                              hint: "e.g., 0.6",
                              icon: Icons.data_usage_rounded,
                            ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _predictGlaucoma,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Analyze Data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ).animate().fadeIn(delay: 800.ms).scale(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Results Card
                  if (_predictionResult != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _getRiskColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getRiskColor().withOpacity(0.5), width: 2),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _predictionResult == 'Glaucoma' ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                size: 48,
                                color: _getRiskColor(),
                              ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
                              const SizedBox(height: 16),
                              Text(
                                _riskLevel ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: _getRiskColor(),
                                ),
                              ).animate().fadeIn().slideY(),
                              const SizedBox(height: 8),
                              Text(
                                "Prediction: $_predictionResult\nConfidence: ${(_confidence! * 100).toStringAsFixed(1)}%",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ).animate().fadeIn(delay: 200.ms),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: const Color(0xFF06B6D4)),
      ),
    );
  }
}
