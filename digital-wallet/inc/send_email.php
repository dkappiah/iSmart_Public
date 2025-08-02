<?php
//Importing PHPMailer classes
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require_once __DIR__ . '/../phpmailer/PHPMailer.php';
require_once __DIR__ . '/../phpmailer/SMTP.php';
require_once __DIR__ . '/../phpmailer/Exception.php';

//A function that sends an email using PHPMailer via Gmail SMTP
function sendEmail($to, $subject, $body) {
    $mail = new PHPMailer(true);

    try {
        //SMTP server settings
        $mail->isSMTP();
        $mail->Host       = 'smtp.gmail.com';
        $mail->SMTPAuth   = true;
        $mail->Username   = 'ajawhary3@gmail.com';
        $mail->Password   = 'lisshfkzqwtjeulq';
        $mail->SMTPSecure = 'tls';
        $mail->Port       = 587;

        //Setting the sender and recipient
        $mail->setFrom('ajawhary3@gmail.com', 'DigiPay');
        $mail->addAddress($to);

        //Content
        $mail->isHTML(true);
        $mail->Subject = $subject;
        $mail->Body    = $body;

        $mail->send();
        return true;
    } catch (Exception $e) {
        error_log("Email failed: {$mail->ErrorInfo}");
        return false;
    }
}
