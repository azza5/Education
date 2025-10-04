<?php
header('Content-Type: application/json');
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

    $query = "SELECT id, nom,student_id FROM matieres";
    $stmt = $pdo->prepare($query);
    $stmt->execute();

    $matieres = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($matieres) > 0) {
         json_encode([
            'success' => true,
            'matieres' => $matieres
        ]);
    } else {
         json_encode([
            'success' => false,
            'message' => 'Aucune matière trouvée'
        ]);
    }
} catch (PDOException $e) {
     json_encode([
        'success' => false,
        'message' => 'Erreur de connexion à la base de données ou de récupération des données',
        'error' => $e->getMessage()
    ]);
}
?>
