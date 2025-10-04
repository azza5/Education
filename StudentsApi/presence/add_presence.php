<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

try {
    $pdo = new PDO('mysql:host=localhost;dbname=studentsbd', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Erreur de connexion à la base de données : " . $e->getMessage()]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

$student_id = $data['student_id'] ?? null;
$matiere_id = $data['matiere_id'] ?? null;
$status = $data['status'] ?? null;

if (empty($student_id) || empty($matiere_id) || empty($status)) {
    echo json_encode(['success' => false, 'message' => 'Tous les champs doivent être remplis.']);
    exit;
}

$date = date('Y-m-d H:i:s'); 

try {
    $query = "INSERT INTO presences (student_id, matiere_id, status, date) 
    VALUES (:student_id, :matiere_id, :status, NOW())";

    
    $stmt = $pdo->prepare($query);
    
    $stmt->bindParam(':student_id', $student_id, PDO::PARAM_INT);
    $stmt->bindParam(':matiere_id', $matiere_id, PDO::PARAM_INT);
    $stmt->bindParam(':status', $status, PDO::PARAM_STR);
    

    $stmt->execute();
    
    $stmt = $pdo->prepare("SELECT id, nom FROM matieres WHERE student_id = :student_id");
    $stmt->bindParam(':student_id', $student_id, PDO::PARAM_INT);
    $stmt->execute();
    $matieres = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'message' => 'Présence ajoutée avec succès !',
        'matieres' => $matieres 
    ]);

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'ajout de la présence : ' . $e->getMessage()]);
}
?>
