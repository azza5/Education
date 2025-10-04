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

        if (isset($data['id']) && isset($data['nom']) && isset($data['prenom']) && isset($data['email']) && isset($data['adresse']) && isset($data['dateNaissance']) && isset($data['role'])) {
            $id = (int) $data['id'];
            $nom = $data['nom'];
            $prenom = $data['prenom'];
            $email = $data['email'];
            $adresse = $data['adresse'];
            $dateNaissance = $data['dateNaissance'];
            $role = $data['role'];

            $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM admin WHERE id = :id");
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($row['count'] == 0) {
                echo json_encode(["success" => false, "message" => "L'administrateur avec cet ID n'existe pas."]);
                exit;
            }

            $stmt = $pdo->prepare("UPDATE admin SET nom = :nom, prenom = :prenom, email = :email, adresse = :adresse, dateNaissance = :dateNaissance, role = :role WHERE id = :id");
            $stmt->bindParam(':nom', $nom, PDO::PARAM_STR);
            $stmt->bindParam(':prenom', $prenom, PDO::PARAM_STR);
            $stmt->bindParam(':email', $email, PDO::PARAM_STR);
            $stmt->bindParam(':adresse', $adresse, PDO::PARAM_STR);
            $stmt->bindParam(':dateNaissance', $dateNaissance, PDO::PARAM_STR);
            $stmt->bindParam(':role', $role, PDO::PARAM_STR);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);

            if ($stmt->execute()) {
                echo json_encode(["success" => true, "message" => "Informations de l'administrateur mises à jour avec succès."]);
            } else {
                echo json_encode(["success" => false, "message" => "Erreur lors de la mise à jour de l'administrateur."]);
            }
        } else {
            echo json_encode(["success" => false, "message" => "Données manquantes. ID, nom, prénom, email, adresse, date de naissance et rôle sont nécessaires."]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de mise à jour : ' . $e->getMessage()
    ]);
}
?>
