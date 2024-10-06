# app.py

from flask import Flask, render_template, redirect, url_for, request, flash
from flask_login import LoginManager, login_user, login_required, logout_user, UserMixin, current_user
import os

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Replace with a secure secret key

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Simple user model
class User(UserMixin):
    def __init__(self, id):
        self.id = id
        self.username = id

# In-memory user store (replace with a database in production)
users = {'admin': {'password': 'password123'}}

@login_manager.user_loader
def load_user(user_id):
    return User(user_id)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        if username in users and users[username]['password'] == password:
            user = User(username)
            login_user(user)
            return redirect(url_for('index'))
        else:
            flash('Invalid username or password.')
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

@app.route('/')
@login_required
def index():
    # Path where HLS playlists are stored
    hls_path = '/tmp/hls'
    streams = []
    for filename in os.listdir(hls_path):
        if filename.endswith('.m3u8'):
            stream_name = filename[:-5]
            streams.append(stream_name)
    return render_template('index.html', streams=streams)

@app.route('/stream/<stream_name>')
@login_required
def stream(stream_name):
    return render_template('stream.html', stream_name=stream_name)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
