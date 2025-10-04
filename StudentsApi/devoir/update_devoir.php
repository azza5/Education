<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$dbname = 'studentsbd';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
        $devoirId = isset($_GET['devoir_id']) ? (int) $_GET['devoir_id'] : null;

        if ($devoirId) {
            $data = json_decode(file_get_contents("php://input"), true);
            $description = $data['description'] ?? null;
            $date = $data['date'] ?? null; // Récupérer la date

            if ($description && $date) { 
                if (strtotime($date)) {
                    $formattedDate = date('Y-m-d H:i:s', strtotime($date)); 
                    $query = "SELECT student_id, matiere_id, date FROM devoirs WHERE id = :devoirId";
                    $stmt = $pdo->prepare($query);
                    $stmt->bindParam(':devoirId', $devoirId);
                    $stmt->execute();
                    $devoir = $stmt->fetch(PDO::FETCH_ASSOC);

                    if ($devoir) {
                        $studentId = $devoir['student_id'];
                        $matiereId = $devoir['matiere_id'];

                        $updateQuery = "UPDATE devoirs SET description = :description, date = :date WHERE id = :devoirId";
                        $updateStmt = $pdo->prepare($updateQuery);
                        $updateStmt->bindParam(':description', $description);
                        $updateStmt->bindParam(':date', $formattedDate);
                        $updateStmt->bindParam(':devoirId', $devoirId);

                        if ($updateStmt->execute()) {
                            echo json_encode(["success" => true, "message" => "Devoir mis à jour avec succès."]);
                        } else {
                            echo json_encode(["success" => false, "message" => "Erreur lors de la mise à jour."]);
                        }
                    } else {
                        echo json_encode(["success" => false, "message" => "Devoir introuvable."]);
                    }
                } else {
                    echo json_encode(["success" => false, "message" => "Date invalide."]);
                }
            } else {
                echo json_encode(["success" => false, "message" => "La description ou la date est manquante."]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "ID du devoir manquant."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Méthode non autorisée."]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données ou de mise à jour',
        'error' => $e->getMessage()
    ]);
}
?>
