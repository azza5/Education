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

        if (isset($data['student_id'])) {
            $studentId = $data['student_id'];
            
            $query = "SELECT id, nom, prenom, email, dateNaissance, adresse, role,classe FROM students WHERE id = :studentId";
            $stmt = $pdo->prepare($query);
            $stmt->bindParam(':studentId', $studentId, PDO::PARAM_INT);
            $stmt->execute();
            $studentInfo = $stmt->fetch(PDO::FETCH_ASSOC);

            if (!$studentInfo) {
                echo json_encode(['success' => false, 'message' => 'Étudiant non trouvé']);
            } else {
                echo json_encode([
                    'success' => true,
                    'studentInfo' => $studentInfo
                ]);
            }
        } else {
            echo json_encode(['success' => false, 'message' => 'ID étudiant manquant']);
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
