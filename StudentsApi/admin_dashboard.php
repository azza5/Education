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

        if (!isset($data['id']) || empty($data['id'])) {
            echo json_encode(['success' => false, 'message' => 'Identifiant administrateur invalide']);
            exit;
        }

        $adminIdentifier = $data['id']; 

        if (is_numeric($adminIdentifier)) {
            $stmt = $pdo->prepare("SELECT id, nom, prenom, email, dateNaissance, adresse, role FROM admin WHERE id = :id");
            $stmt->bindParam(':id', $adminIdentifier, PDO::PARAM_INT);
        } else {
            $stmt = $pdo->prepare("SELECT id, nom, prenom, email, dateNaissance, adresse, role FROM admin WHERE email = :email");
            $stmt->bindParam(':email', $adminIdentifier, PDO::PARAM_STR);
        }

        $stmt->execute();
        $adminInfo = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$adminInfo) {
            echo json_encode(['success' => false, 'message' => "Administrateur non trouvé"]);
            exit;
        }

        echo json_encode([
            'success' => true,
            'adminInfo' => $adminInfo
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Méthode non autorisée']);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données',
        'error' => $e->getMessage(),
    ]);
}
?>
