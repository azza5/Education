<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

$host = 'localhost';
$dbname = 'studentsbd';
$username = 'root';
$password = '';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $input = json_decode(file_get_contents('php://input'), true);
    $email = $input['username'] ?? '';
    $password = $input['password'] ?? '';

    $stmt = $conn->prepare("SELECT * FROM admin WHERE email = ?");
    $stmt->execute([$email]);

    if ($stmt->rowCount() > 0) {
        $admin = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($password === $admin['password']) { 
            echo json_encode(['success' => true, 'message' => 'Connexion réussie', 'role' => 'admin']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Mot de passe incorrect']);
        }
    } else {
        $stmt = $conn->prepare("SELECT * FROM students WHERE email = ?");
        $stmt->execute([$email]);

        if ($stmt->rowCount() > 0) {
            $student = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($password === $student['password']) {
                echo json_encode([
                    'success' => true,
                    'role' => 'student',
                    'student_id' => isset($student['id']) ? $student['id'] : null,   
                    'message' => 'Connexion réussie'
                ]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Mot de passe incorrect']);
            }
        } else {
            echo json_encode(['success' => false, 'message' => 'Email inconnu']);
        }
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Erreur de connexion à la base de données']);
}
?>
