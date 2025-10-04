<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$servername = "localhost"; 
$username = "root"; 
$password = ""; 
$dbname = 'studentsbd';

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["message" => "Connection failed: " . $conn->connect_error]));
}

$studentId = isset($_GET['studentId']) ? $_GET['studentId'] : null;
$matiereId = isset($_GET['matiereId']) ? $_GET['matiereId'] : null;

if ($studentId === null || $matiereId === null) {
    echo json_encode(["message" => "Paramètres manquants"]);
    exit();
}

$sql_devoirs = "SELECT devoirs.id, devoirs.description, matieres.nom AS matiere_nom, devoirs.student_id
                FROM devoirs
                INNER JOIN matieres ON devoirs.matiere_id = matieres.id
                WHERE devoirs.student_id = ? AND devoirs.matiere_id = ?";

$sql_presences = "SELECT status, date FROM presences WHERE student_id = ? AND matiere_id = ?";

$stmt_devoirs = $conn->prepare($sql_devoirs);
$stmt_devoirs->bind_param("ii", $studentId, $matiereId);
$stmt_devoirs->execute();
$result_devoirs = $stmt_devoirs->get_result();

$stmt_presences = $conn->prepare($sql_presences);
$stmt_presences->bind_param("ii", $studentId, $matiereId);
$stmt_presences->execute();
$result_presences = $stmt_presences->get_result();

$devoirs = [];
$presences = [];

if ($result_devoirs->num_rows > 0) {
    while ($row = $result_devoirs->fetch_assoc()) {
        $devoirs[] = $row;
    }
}

if ($result_presences->num_rows > 0) {
    while ($row = $result_presences->fetch_assoc()) {
        $presences[] = $row;
    }
}

echo json_encode([
    'devoirs' => $devoirs,
    'presences' => $presences
]);

$conn->close();
?>
