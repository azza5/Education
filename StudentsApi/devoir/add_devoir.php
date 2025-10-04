<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

try {
    $pdo = new PDO('mysql:host=localhost;dbname=studentsbd', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Erreur de connexion à la base de données : " . $e->getMessage()]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['description'], $data['student_id'], $data['date'], $data['matiere_id'])) {
    $description = $data['description'];
    $student_id = $data['student_id'];
    $date = $data['date'];
    $matiere_id = $data['matiere_id'];

    try {
        $dt = DateTime::createFromFormat('Y-m-d', $date);
        if (!$dt || $dt->format('Y-m-d') !== $date) {
            echo json_encode(["success" => false, "message" => "Format de la date invalide. Veuillez utiliser le format YYYY-MM-DD."]);
            exit;
        }

        $insertStmt = $pdo->prepare("INSERT INTO devoirs (description, matiere_id, student_id, date) VALUES (:description, :matiere_id, :student_id, :date)");
        $insertStmt->bindParam(':description', $description);
        $insertStmt->bindParam(':date', $date);
        $insertStmt->bindParam(':matiere_id', $matiere_id, PDO::PARAM_INT);
        $insertStmt->bindParam(':student_id', $student_id, PDO::PARAM_INT);

        if ($insertStmt->execute()) {
            echo json_encode(["success" => true, "message" => "Devoir ajouté avec succès."]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur lors de l'ajout du devoir."]);
        }
    } catch (PDOException $e) {
        echo json_encode(["success" => false, "message" => "Erreur lors de l'ajout du devoir : " . $e->getMessage()]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Paramètres manquants pour ajouter un devoir."]);
}
?>