<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$dbname = 'studentsbd';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        exit;
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data['student_id']) || !is_numeric($data['student_id'])) {
            echo json_encode(['success' => false, 'message' => 'ID étudiant invalide ou non fourni']);
            exit;
        }

        $studentId = intval($data['student_id']); 

        $stmt = $pdo->prepare("SELECT id, nom, prenom, email, dateNaissance, adresse, role,classe FROM students WHERE id = :studentId");
        $stmt->bindParam(':studentId', $studentId, PDO::PARAM_INT);
        $stmt->execute();
        $studentInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$studentInfo) {
            echo json_encode(['success' => false, 'message' => "Étudiant non trouvé"]);
            exit;
        }

        $stmt = $pdo->prepare("
            SELECT 
    m.id AS matiere_id, m.nom AS matiere_nom, 
    d.id AS devoir_id, d.description AS devoir_description,
    p.date AS presence_date, p.status AS presence_status
FROM matieres m
LEFT JOIN devoirs d ON m.id = d.matiere_id AND d.student_id = :studentId
LEFT JOIN presences p ON m.id = p.matiere_id AND p.student_id = :studentId
WHERE m.student_id = :studentId;

        ");
        $stmt->bindParam(':studentId', $studentId, PDO::PARAM_INT);
        $stmt->execute();
        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $subjects = [];
        foreach ($result as $row) {
            $matiereId = $row['matiere_id'];

            if (!isset($subjects[$matiereId])) {
                $subjects[$matiereId] = [
                    'id' => $matiereId,
                    'nom' => $row['matiere_nom'],
                    'devoirs' => [],
                    'presences' => []
                ];
            }

            if ($row['devoir_id']) {
                $subjects[$matiereId]['devoirs'][] = [
                    'id' => $row['devoir_id'],
                    'description' => $row['devoir_description']
                ];
            }

            if ($row['presence_date']) {
                $subjects[$matiereId]['presences'][] = [
                    'date' => $row['presence_date'],
                    'status' => $row['presence_status']
                ];
            }
        }

        echo json_encode([
            'success' => true,
            'studentInfo' => $studentInfo,
            'subjects' => array_values($subjects),
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données ou de récupération des données',
        'error' => $e->getMessage(),
    ]);
}
?>
