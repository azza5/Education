<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

try {
    $pdo = new PDO('mysql:host=localhost;dbname=studentsbd', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
     json_encode(["success" => false, "message" => "Erreur de connexion à la base de données : " . $e->getMessage()]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['nom']) && isset($data['student_id'])) {
    $nom = $data['nom'];
    $student_id = $data['student_id'];
    
    $stmt = $pdo->prepare("INSERT INTO matieres (nom, student_id) VALUES (:nom, :student_id)");
    $stmt->bindParam(':nom', $nom);
    $stmt->bindParam(':student_id', $student_id);
    
    if ($stmt->execute()) {
         echo json_encode(["success" => true, "message" => "Matière ajoutée avec succès."]);
    } else {
         echo json_encode(["success" => false, "message" => "Erreur lors de l'ajout de la matière."]);
    }
} else {
     echo json_encode(["success" => false, "message" => "Paramètres manquants pour ajouter une matière."]);
}
