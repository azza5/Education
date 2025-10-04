<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$dbname = 'studentsbd';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if (isset($_GET['studentId'])) {
        $studentId = intval($_GET['studentId']); 

        $query = "
            SELECT d.id, d.description, d.matiere_id, m.nom AS matiere_nom, DATE(d.date) AS date 
            FROM devoirs d
            LEFT JOIN matieres m ON d.matiere_id = m.id
            WHERE d.student_id = :studentId
        ";
        $stmt = $pdo->prepare($query);
        $stmt->bindParam(':studentId', $studentId, PDO::PARAM_INT);
        $stmt->execute();

        $devoirs = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($devoirs) > 0) {
            echo json_encode([
                'success' => true,
                'devoirs' => $devoirs
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Aucun devoir trouvé pour cet étudiant'
            ]);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'ID de l\'étudiant manquant'
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données ou de récupération des données',
        'error' => $e->getMessage()
    ]);
}
?>
