<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, OPTIONS");

try {
    $pdo = new PDO('mysql:host=localhost;dbname=studentsbd', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Erreur de connexion à la base de données : " . $e->getMessage()]);
    exit;
}

$matiereId = isset($_GET['matiereId']) ? $_GET['matiereId'] : null;

if ($matiereId) {
    $stmt = $pdo->prepare("SELECT id, student_id, matiere_id, status, 
    IF(date = '0000-00-00 00:00:00', NULL, DATE_FORMAT(date, '%Y-%m-%d %H:%i:%s')) as date 
    FROM presences WHERE matiere_id = :matiereId");
    $stmt->bindParam(':matiereId', $matiereId, PDO::PARAM_INT);
    $stmt->execute();
    $presences = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if ($presences) {
        echo json_encode(["success" => true, "presences" => $presences]);
    } else {
        echo json_encode(["success" => false, "message" => "Aucune présence trouvée pour cette matière."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "ID de matière manquant."]);
}
?>
