<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $pdo = new PDO('mysql:host=localhost;dbname=studentsbd', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $data = json_decode(file_get_contents("php://input"), true);

    if (!$data || !isset($data['id']) || !is_numeric($data['id']) || (int)$data['id'] <= 0) {
        echo json_encode([
            "success" => false,
            "message" => "Données JSON non valides ou ID manquant/incorrect.",
        ]);
        exit;
    }

    $id = (int)$data['id'];

    $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM students WHERE id = :id");
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row || $row['count'] == 0) {
        echo json_encode([
            "success" => false,
            "message" => "L'étudiant avec cet ID n'existe pas.",
        ]);
        exit;
    }

    $tablesToDeleteFrom = ['devoirs', 'matieres', 'presences'];
    foreach ($tablesToDeleteFrom as $table) {
        $stmt = $pdo->prepare("DELETE FROM $table WHERE student_id = :id");
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
    }

    $stmt = $pdo->prepare("DELETE FROM students WHERE id = :id");
    $stmt->bindParam(':id', $id, PDO::PARAM_INT);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo json_encode([
            "success" => true,
            "message" => "Étudiant et ses données associées supprimés avec succès.",
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Erreur lors de la suppression de l'étudiant.",
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Erreur de suppression : " . $e->getMessage(),
    ]);
}
?>
