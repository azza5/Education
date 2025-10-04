<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");  
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE");
header("Access-Control-Allow-Headers: Content-Type, X-Requested-With");

$host = 'localhost';
$dbname = 'studentsbd';
$username = 'root';
$password = '';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $input = json_decode(file_get_contents('php://input'), true);

    $nom = $input['nom'] ?? '';
    $prenom = $input['prenom'] ?? '';
    $email = $input['email'] ?? '';
    $password = $input['password'] ?? '';
    $adresse = $input['adresse'] ?? '';
    $dateNaissance = $input['dateNaissance'] ?? '';
    $role = $input['role'] ?? 'etudiant'; 
    $classe = $input['classe'] ?? '';
    
    if (empty($nom) || empty($prenom) || empty($email) || empty($password) || empty($adresse) || empty($dateNaissance) || empty($role)|| empty($classe)) {
        echo json_encode(['success' => false, 'message' => 'Tous les champs obligatoires doivent être remplis']);
        exit();
    }

    $table = ($role === 'admin') ? 'admin' : 'students';
    $stmt = $conn->prepare("SELECT * FROM $table WHERE email = ?");
    $stmt->execute([$email]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(['success' => false, 'message' => 'Email déjà existant']);
        exit();
    }

    $query = ($role === 'admin') ?
        "INSERT INTO admin (nom, prenom, email, password, adresse, dateNaissance, role) VALUES (?, ?, ?, ?, ?, ?, ?)" :
        "INSERT INTO students (nom, prenom, email, password, adresse, dateNaissance, role,classe) VALUES (?,?, ?, ?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($query);
    if ($stmt->execute([$nom, $prenom, $email, $password, $adresse, $dateNaissance, $role, $classe])) {
        echo json_encode(['success' => true, 'message' => ucfirst($role) . ' enregistré avec succès']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Erreur lors de l\'enregistrement']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur de connexion à la base de données : ' . $e->getMessage()]);
}
?>
