import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:students_app/Admin/Profile.dart';
import 'package:students_app/Admin/UpdateAdminPage.dart';
import 'package:students_app/students/student_data_list.dart';
import 'package:students_app/Devoir/add_devoir_page.dart';
import 'package:students_app/Devoir/list_devoirs.dart';
import 'package:students_app/Presence/AddPresencePage.dart';
import 'package:students_app/Presence/listePresence.dart';
import 'package:students_app/Students/EtudiantDetailPage.dart';
import 'package:students_app/Students/addEtudiant.dart';
import 'package:students_app/students/listEtudiant.dart';
import 'package:students_app/students/studentDashboard.dart';
import 'package:students_app/students/updateEtudiant.dart';
import 'Admin/admin_dashboard.dart';
import 'Auth/loginForm.dart';
import 'Auth/registerPage.dart';
import 'package:intl/intl.dart';

void main() {
  Intl.defaultLocale = 'fr_FR';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion des Étudiants',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('fr', 'FR'),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginForm(),
        '/AdminDashboard': (context) => const AdminDashboard(),
        '/register': (context) => const RegisterPage(),
        '/students': (context) => const ListStudents(),
        '/update_student': (context) => const UpdateStudentPage(student: {}),
        '/studentDash': (context) => const StudentDashboard(studentId: ""),
        '/student_update': (context) => const UpdateStudentPage(student: {}),
        '/add_student': (context) => AddStudentForm(
              onStudentAdded: () {
                Navigator.pushReplacementNamed(context, '/students');
              },
            ),
        '/update_admin': (context) => UpdateAdminPage(
            admin: ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>),
        '/student_data_list': (context) => const StudentDataList(),
        '/admin_profile': (context) => AdminProfilePage(
              adminId: ModalRoute.of(context)?.settings.arguments as String,
            ),
        '/list_devoirs': (context) => ListDevoirs(
              studentId: ModalRoute.of(context)?.settings.arguments as int,
            ),
        '/student_detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return StudentDetailPage(student: args);
        },
        '/add_assignment': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return AddAssignmentPage(
            matiereName: args['matiereName'],
            studentId: args['studentId'],
          );
        },
        '/presence_list': (context) => PresenceListPage(
              studentId: ModalRoute.of(context)?.settings.arguments as int,
            ),
        '/add_presence': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>;
          return AddPresencePage(
            studentId: args['studentId'],
            onPresenceAdded: args['onPresenceAdded'],
          );
        },
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text("Inscription Réussie"),
              backgroundColor: const Color(0xFFFFA726),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Inscription réussie !"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
