import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PresenceListPage extends StatefulWidget {
  final int studentId;

  const PresenceListPage({Key? key, required this.studentId}) : super(key: key);
  @override
  _PresenceListPageState createState() => _PresenceListPageState();
}

class _PresenceListPageState extends State<PresenceListPage> {
  List<Map<String, dynamic>> _presences = [];

  @override
  void initState() {
    super.initState();
    fetchPresences();
  }

  Future<void> fetchPresences() async {
    try {
      final url =
          "http://192.168.101.43/StudentsApi/presence/get_presences.php?student_id=${widget.studentId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            _presences = List<Map<String, dynamic>>.from(data);
          });
        } else if (data is Map && data.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Erreur inconnue')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Format de réponse inattendu.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur (${response.statusCode})')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des présences"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _presences.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _presences.length,
                itemBuilder: (context, index) {
                  final presence = _presences[index];
                  return ListTile(
                    title: Text("Matière: ${presence['matiere']}"),
                    subtitle: Text(
                        "Statut: ${presence['status']}\nDate: ${presence['date']}"),
                  );
                },
              ),
      ),
    );
  }
}
