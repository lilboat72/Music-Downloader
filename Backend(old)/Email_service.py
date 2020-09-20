# TODO: Make a dev account and remove lolzgoat
import smtplib
import ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def sendEmail(FeedbackType,body):
    port = 587 # For starttls
    smtp_server = "smtp.gmail.com"
    password = "1234developer.com" 
    sender_email = "lolzgoat@gmail.com"
    receiver_email = "lolzgoat@gmail.com"
    message = MIMEMultipart("alternative")
    message["Subject"] = FeedbackType

    # write the plain body part
    body = body
    # convert to MIMEText objects and add them to the MIMEMultipart message
    part1 = MIMEText(body, "plain")
    message.attach(part1)

    # send your email
    with smtplib.SMTP(smtp_server, port) as server:
        server.starttls()
        server.login(sender_email, password)
        server.sendmail(
            sender_email, receiver_email, message.as_string()
        )
    print(f'Email Sent to {receiver_email}') 


