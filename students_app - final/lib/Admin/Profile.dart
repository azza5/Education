import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:students_app/Admin/UpdateAdminPage.dart';

class AdminProfilePage extends StatefulWidget {
  final String adminId;
  const AdminProfilePage({Key? key, required this.adminId}) : super(key: key);

  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  Map<String, dynamic>? adminInfo;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    var url =
        Uri.parse("http://192.168.101.43/StudentsApi/admin_dashboard.php");
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"id": widget.adminId}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            adminInfo = data['adminInfo'];
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

  void _navigateToUpdatePage() async {
    bool? isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateAdminPage(admin: adminInfo!),
      ),
    );

    if (isUpdated == true) {
      _fetchAdminData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (adminInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profil Admin"),
          backgroundColor: const Color(0xFFFFA726),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Administrateur"),
        backgroundColor: const Color(0xFFFFA726),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _navigateToUpdatePage,
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
              _buildTextWithBorder("Nom :", "${adminInfo!['nom']}"),
              _buildTextWithBorder("Prénom :", "${adminInfo!['prenom']}"),
              _buildTextWithBorder("Email :", "${adminInfo!['email']}"),
              _buildTextWithBorder("Adresse :", "${adminInfo!['adresse']}"),
              _buildTextWithBorder(
                  "Date de naissance :", "${adminInfo!['dateNaissance']}"),
              _buildTextWithBorder("Rôle :", "${adminInfo!['role']}"),
              const SizedBox(height: 20),
              _buildActionButton(
                text: "Modifier les informations",
                onPressed: () {
                  _navigateToUpdatePage();
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
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
