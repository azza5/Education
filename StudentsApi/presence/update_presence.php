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

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $studentId = isset($data['studentId']) ? $data['studentId'] : null;
    $matiereId = isset($data['matiereId']) ? $data['matiereId'] : null;
    $presenceId = isset($data['presenceId']) ? $data['presenceId'] : null;
    $status = isset($data['status']) ? $data['status'] : null;

    if ($studentId && $matiereId && $presenceId && $status) {
        $query = "UPDATE presences SET status = ?, date = NOW() WHERE student_id = ? AND matiere_id = ? AND id = ?";
        $stmt = $pdo->prepare($query);
        $stmt->bindParam(1, $status);
        $stmt->bindParam(2, $studentId, PDO::PARAM_INT);
        $stmt->bindParam(3, $matiereId, PDO::PARAM_INT);
        $stmt->bindParam(4, $presenceId, PDO::PARAM_INT);

        $result = $stmt->execute();

        if ($result) {
            echo json_encode(["message" => "Présence mise à jour avec succès"]);
        } else {
            echo json_encode(["message" => "Erreur lors de la mise à jour"]);
        }
    } else {
        echo json_encode(["message" => "Paramètres manquants"]);
    }
}
?>