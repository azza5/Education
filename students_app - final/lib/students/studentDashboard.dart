import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:students_app/students/updateEtudiant.dart';

class StudentDashboard extends StatefulWidget {
  final String studentId;
  const StudentDashboard({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Map<String, dynamic> studentInfo = {};
  List<dynamic> subjects = [];
  List<dynamic> homeworks = [];
  List<dynamic> attendance = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentDashboardData();
  }

  Future _fetchStudentDashboardData() async {
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/students/student_dashboard.php");
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"student_id": widget.studentId}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            // Mise à jour de l'état avec les données récupérées
            studentInfo = data['studentInfo'] ?? {};
            subjects = data['subjects'] ?? [];
            homeworks = data['homeworks'] ?? [];
            attendance = data['attendance'] ?? [];
          });
        } else {
          _showErrorDialog(data['message']);
        }
      } else {
        _showErrorDialog("Erreur lors de la récupération des données.");
      }
    } catch (e) {
      _showErrorDialog("Problème de connexion au serveur.");
    }
  }

  Future<List<dynamic>> _fetchPresences(String matiereId) async {
    var url = Uri.parse(
        "http://192.168.101.43/StudentsApi/presence/get_presences.php?matiereId=$matiereId");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == true) {
          return data['presences'];
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des présences: $e');
    }

    return [];
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Erreur"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Déconnexion"),
          content: const Text("Voulez-vous vraiment vous déconnecter ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/");
              },
              child: const Text("Déconnexion"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text('Tableau de bord de l\'étudiant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.green),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: studentInfo.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                          "${studentInfo['nom']} ${studentInfo['prenom']}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email: ${studentInfo['email']}"),
                          Text("Classe: ${studentInfo['classe']}"),
                          Text(
                              "Date de naissance: ${studentInfo['dateNaissance']}"),
                          Text("Adresse: ${studentInfo['adresse']}"),
                          Text("Rôle: ${studentInfo['role']}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UpdateStudentPage(student: studentInfo),
                                ),
                              );
                            },
                          ),
                          const Icon(Icons.person),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Matières"),
                  _buildSubjectsList(),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
      ),
    );
  }

  Widget _buildSubjectsList() {
    if (subjects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Aucune matière disponible."),
      );
    }

    return Column(
      children: subjects.map<Widget>((subject) {
        return FutureBuilder<List<dynamic>>(
          future: _fetchPresences(subject['id'].toString()),
          builder: (context, snapshot) {
            List<dynamic> presences = snapshot.data ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              shadowColor: Colors.grey.shade200,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(subject['nom']),
                leading: const Icon(Icons.book),
                children: [
                  _buildHomeworksList(subject['devoirs']),
                  _buildPresencesList(presences),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildHomeworksList(List<dynamic> homeworks) {
    if (homeworks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Aucun devoir à afficher."),
      );
    }
    return Column(
      children: homeworks.map<Widget>((homework) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.white,
          shadowColor: Colors.grey.shade200,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(homework['description']),
            leading: const Icon(Icons.assignment),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPresencesList(List<dynamic> presences) {
    if (presences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Aucune présence enregistrée."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: presences.map<Widget>((presence) {
        String formattedDate = presence['date'];
        if (formattedDate.isNotEmpty &&
            formattedDate != "0000-00-00 00:00:00") {
          try {
            DateTime date = DateTime.parse(formattedDate);
            formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
          } catch (e) {
            formattedDate = "Format invalide";
          }
        } else {
          formattedDate = "Donnée indisponible";
        }

        return ListTile(
          title: Text("Présence: ${presence['status']}"),
          subtitle: Text("Date: $formattedDate"),
          leading: const Icon(Icons.check_circle),
        );
      }).toList(),
    );
  }
}
