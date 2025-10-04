<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

try {
    $pdo = new PDO('mysql:host=localhost;dbname=studentsbd', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Erreur de connexion à la base de données : " . $e->getMessage()]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['nom'], $data['email'], $data['adresse'], $data['prenom'], $data['password'], $data['dateNaissance'],$data['role'], $data['classe'])) {
    $nom = $data['nom'];
    $email = $data['email'];
    $adresse = $data['adresse'];
    $prenom = $data['prenom'];
    $password = $data['password'];
    $dateNaissance = $data['dateNaissance'];
    $role = $data['role'];
    $classe = !empty($data['classe']) ? $data['classe'] : 'Non spécifié';



    $stmt = $pdo->prepare("
        INSERT INTO students (nom, email, adresse, prenom,password, dateNaissance,role,classe) 
        VALUES (:nom, :email, :adresse, :prenom, :password, :dateNaissance, :role ,:classe)
    ");
    $stmt->bindParam(':nom', $nom);
    $stmt->bindParam(':email', $email);
    $stmt->bindParam(':adresse', $adresse);
    $stmt->bindParam(':prenom', $prenom);
    $stmt->bindParam(':dateNaissance', $dateNaissance);
    $stmt->bindParam(':password', $password);
    $stmt->bindParam(':role', $role);
    $stmt->bindParam(':classe', $classe);



    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Étudiant ajouté avec succès."]);
    } else {
        echo json_encode(["success" => false, "message" => "Erreur lors de l'ajout de l'étudiant."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Paramètres manquants."]);
}
?>
