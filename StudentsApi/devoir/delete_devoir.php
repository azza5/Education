<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$dbname = 'studentsbd';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
        $data = json_decode(file_get_contents("php://input"), true);

        if (isset($data['devoir_id'])) {
            $devoirId = $data['devoir_id'];

            $query = "DELETE FROM devoirs WHERE id = :devoirId";
            $stmt = $pdo->prepare($query);
            $stmt->bindParam(':devoirId', $devoirId);

            if ($stmt->execute()) {
                echo json_encode(["success" => true, "message" => "Devoir supprimé avec succès."]);
            } else {
                echo json_encode(["success" => false, "message" => "Erreur lors de la suppression du devoir."]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "ID du devoir manquant"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Méthode non autorisée"]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données ou de suppression',
        'error' => $e->getMessage()
    ]);
}
?>
