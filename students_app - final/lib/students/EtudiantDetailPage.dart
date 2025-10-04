import 'package:flutter/material.dart';
import 'package:students_app/Devoir/list_devoirs.dart';
import 'package:students_app/Students/updateEtudiant.dart';
import 'package:students_app/matiere/listMatiere.dart';

class StudentDetailPage extends StatelessWidget {
  final Map<String, dynamic>? student;

  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    if (student == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Erreur"),
          backgroundColor: const Color(0xFFFFA726),
        ),
        body: const Center(
          child: Text(
            "Aucun détail d'étudiant disponible",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Les détails de l'étudiant"),
        backgroundColor: const Color(0xFFFFA726),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateStudentPage(student: student!),
                ),
              );
              if (updated == true) {
                Navigator.pop(context, true);
              }
            },
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildTextWithBorder("Nom :", "${student!['nom']}"),
              _buildTextWithBorder("Prénom :", "${student!['prenom']}"),
              _buildTextWithBorder("Email :", "${student!['email']}"),
              _buildTextWithBorder("Classe :", "${student!['classe']}"),
              _buildTextWithBorder("Adresse :", "${student!['adresse']}"),
              _buildTextWithBorder(
                  "Date de naissance :", "${student!['dateNaissance']}"),
              _buildTextWithBorder("Rôle :", "${student!['role']}"),
              const SizedBox(height: 20),
              _buildActionButton(
                text: "Modifier les informations",
                onPressed: () async {
                  bool? updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateStudentPage(student: student!),
                    ),
                  );
                  if (updated == true) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                text: "Voir les matières de l'étudiant",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListMatieres(
                        studentId: student!['id'],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                text: "Voir les devoirs de l'étudiant",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListDevoirs(
                        studentId: student!['id'],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextWithBorder(String title, String content) {
    return Card(
      margin:
          const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      color: Colors.white,
      shadowColor: Colors.grey.shade300,
      elevation: 4, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFA726),
              ),
            ),
            const SizedBox(
                height: 4), 
            Text(
              content,
              style: const TextStyle(
                fontSize: 18, 
                color: Color.fromARGB(255, 8, 8, 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      {required String text, required VoidCallback onPressed}) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA726),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10), 
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
