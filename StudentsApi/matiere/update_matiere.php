<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$dbname = 'studentsbd';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $data = json_decode(file_get_contents("php://input"), true);
    $studentId = intval($data['student_id'] ?? 0);
    $matiereId = intval($data['id'] ?? 0);
    $newName = $data['nom'] ?? '';  

    if (empty($studentId) || empty($matiereId) || empty($newName)) {
        echo json_encode(['success' => false, 'message' => 'Données manquantes']);
        exit;
    }

    $query = "UPDATE matieres SET nom = :new_name WHERE student_id = :student_id AND id = :matiere_id";
    $stmt = $pdo->prepare($query);
    $stmt->bindParam(':new_name', $newName);
    $stmt->bindParam(':student_id', $studentId);
    $stmt->bindParam(':matiere_id', $matiereId);

    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo json_encode(['success' => true, 'message' => 'Matière mise à jour']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Aucune matière trouvée à mettre à jour']);
    }

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur de connexion à la base de données: ' . $e->getMessage()]);
}
?>
