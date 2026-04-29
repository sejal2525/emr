import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:health_app/screens/transcriptionScreen.dart';
import 'package:health_app/services/firebase_services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? docID;

  @override
  void initState() {
    super.initState();
    getDoctorID();
  }

  Future<void> getDoctorID() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final userData = query.docs.first.data();
      setState(() {
        docID = userData['docID'] ?? userData['uid'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
    }
  }

  void _showAddEventDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController ageController = TextEditingController();
    TextEditingController pidController = TextEditingController();
    TextEditingController didController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.9),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Add New Patient",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(controller: nameController, label: "Patient Name", icon: Icons.person),
                    const SizedBox(height: 12),
                    _buildInputField(controller: phoneController, label: "Phone Number", icon: Icons.phone),
                    const SizedBox(height: 12),
                    _buildInputField(controller: ageController, label: "Age", icon: Icons.cake),
                    const SizedBox(height: 12),
                    _buildInputField(controller: pidController, label: "Patient ID", icon: Icons.badge),
                    const SizedBox(height: 12),
                    _buildInputField(controller: didController, label: "Doctor ID", icon: Icons.medical_services),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (nameController.text.isNotEmpty &&
                                phoneController.text.isNotEmpty &&
                                ageController.text.isNotEmpty &&
                                pidController.text.isNotEmpty &&
                                didController.text.isNotEmpty) {
                              _firebaseService.addDocument(
                                  nameController.text,
                                  phoneController.text,
                                  ageController.text,
                                  pidController.text,
                                  didController.text);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("Save Record"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label, required IconData icon}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF06B6D4)),
      ),
    );
  }

  Widget _buildAnalyticsChart(List<QueryDocumentSnapshot> patients) {
    // Categorize patients by age
    int age0to20 = 0, age21to40 = 0, age41to60 = 0, age60plus = 0;
    
    for (var doc in patients) {
      final data = doc.data() as Map<String, dynamic>;
      final ageStr = data['age'].toString();
      final age = int.tryParse(ageStr) ?? 0;
      
      if (age <= 20) age0to20++;
      else if (age <= 40) age21to40++;
      else if (age <= 60) age41to60++;
      else age60plus++;
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Patient Age Demographics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: patients.length.toDouble() > 0 ? patients.length.toDouble() : 5,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(color: Colors.white54, fontSize: 10);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = '0-20'; break;
                          case 1: text = '21-40'; break;
                          case 2: text = '41-60'; break;
                          case 3: text = '60+'; break;
                          default: text = ''; break;
                        }
                        return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: age0to20.toDouble(), color: const Color(0xFF06B6D4), width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: age21to40.toDouble(), color: const Color(0xFF06B6D4), width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: age41to60.toDouble(), color: const Color(0xFF06B6D4), width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: age60plus.toDouble(), color: const Color(0xFF06B6D4), width: 16, borderRadius: BorderRadius.circular(4))]),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Patients"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _showAddEventDialog(context),
          ).animate().fadeIn().scale(),
        ],
      ),
      body: docID == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .where('docID', isEqualTo: docID)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF06B6D4)));
                }

                final patients = snapshot.data!.docs;

                return CustomScrollView(
                  slivers: [
                    if (patients.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildAnalyticsChart(patients),
                      ),
                    
                    if (patients.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline, size: 64, color: Colors.white24),
                              const SizedBox(height: 16),
                              const Text("No patients found.", style: TextStyle(color: Colors.white54, fontSize: 16)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showAddEventDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text("Add First Patient"),
                              ),
                            ],
                          ).animate().fadeIn(delay: 200.ms),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final data = patients[index].data() as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        leading: CircleAvatar(
                                          backgroundColor: const Color(0xFF06B6D4).withOpacity(0.2),
                                          child: Text(
                                            data['name'].toString().substring(0, 1).toUpperCase(),
                                            style: const TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text(
                                          data['name'],
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          "Age: ${data['age']} • ID: ${data['patID']}",
                                          style: const TextStyle(color: Colors.white54),
                                        ),
                                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white30),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => TranscriptionScreen(data: data)),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: (400 + (100 * index)).ms).slideX(begin: 0.1);
                            },
                            childCount: patients.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
