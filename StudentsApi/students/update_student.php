<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

try {
    $pdo = new PDO('mysql:host=localhost;dbname=studentsbd', 'root', '');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $data = json_decode(file_get_contents("php://input"), true);

    if (isset($data['id']) && isset($data['nom']) && isset($data['email']) && isset($data['adresse']) && isset($data['dateNaissance'])) {
        $id = (int) $data['id'];
        $nom = $data['nom'];
        $email = $data['email'];
        $adresse = $data['adresse'];
        $dateNaissance = $data['dateNaissance'];
        $classe = $data['classe'];


        $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM students WHERE id = :id");
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row['count'] == 0) {
            echo json_encode(["success" => false, "message" => "L'étudiant avec cet ID n'existe pas."]);
            exit;
        }

        $stmt = $pdo->prepare("UPDATE students SET nom = :nom, email = :email, adresse = :adresse, dateNaissance = :dateNaissance,classe = :classe WHERE id = :id");
        $stmt->bindParam(':nom', $nom, PDO::PARAM_STR);
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->bindParam(':adresse', $adresse, PDO::PARAM_STR);
        $stmt->bindParam(':dateNaissance', $dateNaissance, PDO::PARAM_STR);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':classe', $classe, PDO::PARAM_STR);


        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Informations de l'étudiant mises à jour avec succès."]);
        } else {
            echo json_encode(["success" => false, "message" => "Erreur lors de la mise à jour de l'étudiant."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Données manquantes. ID, nom, email, téléphone et date de naissance sont nécessaires."]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Erreur de mise à jour : " . $e->getMessage()]);
}
?> 