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

    if (isset($_GET['student_id']) && !empty($_GET['student_id'])) {
        $studentId = (int) $_GET['student_id'];

        $query = "SELECT m.id, m.nom AS matiere 
                  FROM matieres m 
                  WHERE m.student_id = :student_id 
                  ORDER BY m.nom";
        $stmt = $pdo->prepare($query);
        $stmt->bindParam(':student_id', $studentId, PDO::PARAM_INT);
        
        $stmt->execute();
        $matieres = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (count($matieres) > 0) {
            echo json_encode($matieres);
        } else {
            echo json_encode(['message' => 'Aucune matière trouvée pour cet étudiant.']);
        }
    } else {
        echo json_encode(['message' => 'L\'ID de l\'étudiant est manquant.']);
    }

} catch (PDOException $e) {
    echo json_encode(['error' => 'Erreur de connexion à la base de données: ' . $e->getMessage()]);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $studentId = isset($_POST['student_id']) ? (int) $_POST['student_id'] : 0;  
    $matiereId = isset($_POST['matiere_id']) ? (int) $_POST['matiere_id'] : 0; 
    $nomMatiere = isset($_POST['nom']) ? $_POST['nom'] : '';

    if ($studentId > 0 && $matiereId > 0 && !empty($nomMatiere)) {
        $query = "UPDATE matieres SET nom = :nom WHERE id = :matiere_id AND student_id = :student_id";
        $stmt = $pdo->prepare($query);
        $stmt->bindParam(':nom', $nomMatiere);
        $stmt->bindParam(':matiere_id', $matiereId, PDO::PARAM_INT);
        $stmt->bindParam(':student_id', $studentId, PDO::PARAM_INT);
        
        $stmt->execute();
        echo json_encode(['success' => true, 'message' => 'Matière mise à jour avec succès.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Données invalides.']);
    }
}
?>
