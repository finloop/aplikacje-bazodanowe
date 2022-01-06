import os
import psycopg2
from dotenv import load_dotenv
from flask import Flask, render_template

load_dotenv()  # Load .env file

POSTGRES_HOST = "localhost"
POSTGRES_DB_NAME = "postgres"
POSTGRES_USER = "postgres"
POSTGRES_PASSWORD = os.environ.get('POSTGRES_PASSWORD')


conn = psycopg2.connect(dbname=POSTGRES_DB_NAME,
                        user=POSTGRES_USER,
                        password=POSTGRES_PASSWORD,
                        host=POSTGRES_HOST)
curr = conn.cursor()
app = Flask(__name__)

@app.route('/status')
def status():
    return "I'm alive!!!"

@app.route('/restaurants')
def restaurants():
    return render_template("restaurants.html")
