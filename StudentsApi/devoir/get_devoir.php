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

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = json_decode(file_get_contents("php://input"), true);

        if (isset($data['devoir_id'])) {
            $devoirId = $data['devoir_id'];
            
            $query = "SELECT id, description, matiere_id, student_id,date FROM devoirs WHERE id = :devoirId";
            $stmt = $pdo->prepare($query);
            $stmt->bindParam(':devoirId', $devoirId, PDO::PARAM_INT);
            $stmt->execute();
            $devoirInfo = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$devoirInfo) {
                echo json_encode(['success' => false, 'message' => 'Devoir non trouvé']);
                exit();
            }

            error_log("Informations du devoir: " . json_encode($devoirInfo));

            echo json_encode([
                'success' => true,
                'devoirInfo' => $devoirInfo
            ]);

        } else {
            echo json_encode(['success' => false, 'message' => 'ID du devoir manquant']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données ou de récupération des données',
        'error' => $e->getMessage()
    ]);
}
?>
