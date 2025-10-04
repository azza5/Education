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

if (isset($data['student_id'])) {
    $student_id = $data['student_id'];

    $stmt = $pdo->prepare("SELECT * FROM presences WHERE student_id = :student_id");
    $stmt->bindParam(':student_id', $student_id, PDO::PARAM_INT);
    $stmt->execute();

    $presences = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($presences) {
        echo json_encode([
            "success" => true,
            "presences" => $presences
        ]);
    } else {
        echo json_encode(["success" => false, "message" => "Aucune présence trouvée pour cet étudiant."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "ID de l'étudiant manquant."]);
}
?>
