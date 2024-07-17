from flask import Flask, request, render_template, redirect, url_for, session, flash
from flask_mail import Mail, Message
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import logging
import requests
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)
app.secret_key = 'f0ckeh8wPoLrXMPKx4vbq9915QKY3wKE'  # Add a secret key for session management

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Set up database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///visits.db'
db = SQLAlchemy(app)

class Visit(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    ip_address = db.Column(db.String(15))
    location = db.Column(db.String(100))
    visit_time = db.Column(db.DateTime, default=datetime.utcnow)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)

# Set up Flask-Mail
app.config['MAIL_SERVER'] = 'smtp.office365.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv('SENDER_EMAIL')
app.config['MAIL_PASSWORD'] = os.getenv('EMAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('SENDER_EMAIL')

mail = Mail(app)

# Ensure the database tables are created within the application context
with app.app_context():
    db.create_all()

@app.route('/')
def index():
    log_visit(request)
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        hashed_password = generate_password_hash(password, method='sha256')

        new_user = User(username=username, password=hashed_password)
        db.session.add(new_user)
        db.session.commit()
        flash('Registration successful! Please log in.')
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        
        if user and check_password_hash(user.password, password):
            session['logged_in'] = True
            session['username'] = user.username
            return redirect(url_for('file_generator'))
        else:
            flash('Invalid credentials. Please try again.')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session['logged_in'] = False
    session.pop('username', None)
    return redirect(url_for('index'))

@app.route('/visitors')
def show_visitors():
    visits = Visit.query.all()
    return render_template('visitors.html', visits=visits)

@app.route('/send-email', methods=['POST'])
def send_email():
    name = request.form['name']
    email = request.form['email']
    message = request.form['message']

    if send_email_to_you(name, email, message):
        logging.info('Email sent successfully')
        return 'Thank you for your message! We will get back to you shortly.'
    else:
        logging.error('Failed to send email')
        return 'Failed to send your message. Please try again later.'

def send_email_to_you(name, email, message):
    sender_email = os.getenv('SENDER_EMAIL')
    receiver_email = os.getenv('RECEIVER_EMAIL')
    password = os.getenv('EMAIL_PASSWORD')

    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = 'New Contact Form Submission'

    body = 'Name: {}\nEmail: {}\nMessage: {}'.format(name, email, message)
    msg.attach(MIMEText(body, 'plain'))

    try:
        logging.debug('Connecting to SMTP server')
        server = smtplib.SMTP('smtp.office365.com', 587)
        server.starttls()
        logging.debug('Logging in to SMTP server')
        server.login(sender_email, password)
        logging.debug('Sending email')
        text = msg.as_string()
        server.sendmail(sender_email, receiver_email, text)
        server.quit()
        logging.info('Email sent successfully')
        return True
    except smtplib.SMTPException as e:
        logging.error('SMTP error: {}'.format(e))
        return False
    except Exception as e:
        logging.error('General error: {}'.format(e))
        return False

def log_visit(request):
    ip_address = request.remote_addr
    location = get_location(ip_address)
    visit = Visit(ip_address=ip_address, location=location)
    db.session.add(visit)
    db.session.commit()

def get_location(ip_address):
    try:
        logging.debug(f'Fetching location for IP address: {ip_address}')
        response = requests.get(f'http://ip-api.com/json/{ip_address}')
        data = response.json()
        logging.debug(f'Response from IP API: {data}')
        if (data['status'] == 'fail'):
            logging.error(f'Failed to fetch location for IP address: {ip_address}, Reason: {data["message"]}')
            return "Unknown"
        location = f"{data.get('city', 'Unknown')}, {data.get('country', 'Unknown')}"
        logging.debug(f'Location for IP address {ip_address}: {location}')
        return location
    except Exception as e:
        logging.error(f'Error fetching location: {e}')
        return "Unknown"

@app.route('/file-generator')
def file_generator():
    if not session.get('logged_in'):
        return redirect(url_for('login'))
    return render_template('file_generator.html')

@app.route('/main-page')
def main_page():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)



