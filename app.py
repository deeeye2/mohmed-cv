from flask import Flask, request, jsonify, render_template, redirect, url_for, flash, session
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
from datetime import datetime, timedelta
from flask_mail import Mail, Message
from dotenv import load_dotenv
import os
import jwt
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import logging
import requests

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('SECRET_KEY', 'default_secret_key')

# Set up logging
logging.basicConfig(level=logging.DEBUG)

# Set up database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
db = SQLAlchemy(app)

# Set up Flask-Mail
app.config['MAIL_SERVER'] = 'smtp.office365.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = os.getenv('SENDER_EMAIL')
app.config['MAIL_PASSWORD'] = os.getenv('EMAIL_PASSWORD')
app.config['MAIL_DEFAULT_SENDER'] = os.getenv('SENDER_EMAIL')

mail = Mail(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)

class Visit(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    ip_address = db.Column(db.String(15))
    location = db.Column(db.String(100))
    visit_time = db.Column(db.DateTime, default=datetime.utcnow)

# Ensure the database tables are created within the application context
with app.app_context():
    db.create_all()

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

def token_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({'message': 'Token is missing!'}), 401
        try:
            data = jwt.decode(token, app.secret_key, algorithms=["HS256"])
            current_user = User.query.filter_by(id=data['user_id']).first()
        except:
            return jsonify({'message': 'Token is invalid!'}), 401
        return f(current_user, *args, **kwargs)
    return decorated_function

@app.route('/')
def index():
    log_visit(request)
    send_email_notification()
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        hashed_password = generate_password_hash(password, method='pbkdf2:sha256')

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
        token = request.form['token']
        user = User.query.filter_by(username=username).first()

        if user and check_password_hash(user.password, password):
            try:
                decoded = jwt.decode(token, app.secret_key, algorithms=["HS256"])
                if decoded['user_id'] == user.id:
                    session['user_id'] = user.id
                    flash('Login successful!')
                    return redirect(url_for('file_generator'))
                else:
                    flash('Invalid token')
            except jwt.ExpiredSignatureError:
                flash('Token expired')
            except jwt.InvalidTokenError:
                flash('Invalid token')
        else:
            flash('Invalid username or password')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user_id', None)
    flash('You have been logged out.')
    return redirect(url_for('login'))

@app.route('/file-generator')
@login_required
def file_generator():
    return render_template('file_generator.html')

@app.route('/main-page')
def main_page():
    session.clear()
    return redirect(url_for('register'))

@app.route('/api/login', methods=['POST'])
def api_login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    user = User.query.filter_by(username=username).first()

    if user and check_password_hash(user.password, password):
        token = jwt.encode({'user_id': user.id, 'exp': datetime.utcnow() + timedelta(minutes=1)}, app.secret_key)
        return jsonify({'token': token})
    else:
        return jsonify({'message': 'Invalid username or password'}), 401

@app.route('/api/verify_token', methods=['POST'])
def verify_token():
    data = request.json
    username = data.get('username')
    token = data.get('token')
    try:
        decoded = jwt.decode(token, app.secret_key, algorithms=["HS256"])
        user = User.query.filter_by(id=decoded['user_id']).first()
        if user and user.username == username:
            return jsonify({'message': 'Token verified'}), 200
    except jwt.ExpiredSignatureError:
        return jsonify({'message': 'Token expired'}), 401
    except jwt.InvalidTokenError:
        return jsonify({'message': 'Invalid token'}), 401
    return jsonify({'message': 'Invalid username or token'}), 401

@app.route('/generate/k8s', methods=['POST'])
@token_required
def generate_k8s(current_user):
    data = request.json.get('data')
    # Process data and generate Kubernetes manifest
    return jsonify({"message": "Kubernetes manifest generated", "data": data})

@app.route('/generate/dockerfile', methods=['POST'])
@token_required
def generate_dockerfile(current_user):
    data = request.json.get('data')
    # Process data and generate Dockerfile
    return jsonify({"message": "Dockerfile generated", "data": data})

@app.route('/generate/ansible', methods=['POST'])
@token_required
def generate_ansible(current_user):
    data = request.json.get('data')
    # Process data and generate Ansible playbook
    return jsonify({"message": "Ansible playbook generated", "data": data})

@app.route('/generate/terraform', methods=['POST'])
@token_required
def generate_terraform(current_user):
    data = request.json.get('data')
    # Process data and generate Terraform configuration
    return jsonify({"message": "Terraform configuration generated", "data": data})

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
        if data['status'] == 'fail':
            logging.error(f'Failed to fetch location for IP address: {ip_address}')
            return "Unknown"
        location = f"{data['city']}, {data['country']}"
        logging.debug(f'Location for IP address {ip_address}: {location}')
        return location
    except Exception as e:
        logging.error('Error fetching location: {}'.format(e))
        return "Unknown"

def send_email_notification():
    try:
        msg = Message(
            subject="New Visitor Notification",
            body="A new user has visited your website.",
            recipients=[os.getenv('RECEIVER_EMAIL')]
        )
        mail.send(msg)
        logging.info('Visitor notification email sent successfully')
    except Exception as e:
        logging.error(f'Error sending notification email: {e}')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)



