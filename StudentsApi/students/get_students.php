<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

try {
    $pdo = new PDO('mysql:host=localhost;dbname=studentsbd', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->query("SELECT id, nom, email, adresse ,prenom ,dateNaissance,role,classe FROM students");
    $students = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $students = array_map(function($student) {
        $student['id'] = (int) $student['id'];
        return $student;
    }, $students);

    echo json_encode([
        "success" => true,
        "students" => $students,
    ]);
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Erreur lors de la récupération des étudiants : " . $e->getMessage(),
    ]);
    exit;
}
?>
