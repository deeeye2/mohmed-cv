from flask import Flask, request, render_template
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/send-email', methods=['POST'])
def send_email():
    name = request.form['name']
    email = request.form['email']
    message = request.form['message']

    if send_email_to_you(name, email, message):
        return 'Thank you for your message! We will get back to you shortly.'
    else:
        return 'Failed to send your message. Please try again later.'

def send_email_to_you(name, email, message):
    sender_email = "dee.eye@hotmail.com"
    receiver_email = "dee.eye@hotmail.com"
    password = "Sierraleone1@"

    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = 'New Contact Form Submission'

    body = 'Name: {}\nEmail: {}\nMessage: {}'.format(name, email, message)
    msg.attach(MIMEText(body, 'plain'))

    try:
        # Use Hotmail/Outlook SMTP server
        server = smtplib.SMTP('smtp.office365.com', 587)
        server.starttls()
        server.login(sender_email, password)
        text = msg.as_string()
        server.sendmail(sender_email, receiver_email, text)
        server.quit()
        print('Email sent successfully')
        return True
    except Exception as e:
        print('Error: {}'.format(e))
        return False

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
