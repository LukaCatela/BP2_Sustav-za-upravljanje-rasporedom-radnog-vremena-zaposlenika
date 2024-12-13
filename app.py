from flask import Flask,jsonify, Response, render_template
from flask_sqlalchemy import SQLAlchemy 
from sqlalchemy import text
import json

app = Flask(__name__, template_folder='templates', static_folder='static')

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:luka23012005@127.0.0.1:3306/bp_2_projekt?charset=utf8mb4'
app.config['SQLALCHEMY_TRACK_MODI FICATIONS'] = False

db = SQLAlchemy(app)

@app.route('/')
def index():
    return render_template('index.html')

# Pomocna funkcija za lakse upisivanje tablica sa podatcima
def stavljanje_vrijednosti(ime_tablice):
    with db.engine.connect() as conn:
        query = text(f"SELECT * FROM {ime_tablice}")
        result = conn.execute(query)
        data = [dict(row._mapping) for row in result]
    return data

# Od ovuda do slijedeceg komentara su svi routovi koji koriste pomocnu funkciju
# -----------------------------------------------------------------------------------------------------#
@app.route('/bolovanje', methods=['GET'])
def get_bolovanje():
    return jsonify(stavljanje_vrijednosti('bolovanje'))
@app.route('/kalendar_godisnjih_odmora', methods=['GET'])
def get_kalendar_godisnjih_odmora():
    return jsonify(stavljanje_vrijednosti('kalendar_godisnjih_odmora'))
@app.route('/ogranicenja_tvrtke', methods=['GET'])
def get_ogranicenja_tvrtke():
    return jsonify(stavljanje_vrijednosti('ogranicenja_tvrtke'))
@app.route('/place', methods=['GET'])
def get_place():
    return jsonify(stavljanje_vrijednosti('place'))
@app.route('/prisutnost', methods=['GET'])
def get_prisutnost():
    return jsonify(stavljanje_vrijednosti('prisutnost'))
@app.route('/radni_sati', methods=['GET'])
def get_radni_sati():
    return jsonify(stavljanje_vrijednosti('radni_sati'))
@app.route('/raspored_rada', methods=['GET'])
def get_raspored_rada():
    return jsonify(stavljanje_vrijednosti('raspored_rada'))
@app.route('/smjene', methods=['GET'])
def get_smjene():
    return jsonify(stavljanje_vrijednosti('smjene'))
@app.route('/zahtjev_prekovremeni', methods=['GET'])
def get_zahtjev_prekovremeni():
    return jsonify(stavljanje_vrijednosti('zahtjev_prekovremeni'))
@app.route('/zahtjevni_godisnji_odmor', methods=['GET'])
def get_zahtjevni_godisnji_odmor():
    return jsonify(stavljanje_vrijednosti('zahtjevni_godisnji_odmor'))
@app.route('//zaposlenici',methods=['GET'])
def get_zaposlenici():
    return jsonify(stavljanje_vrijednosti('zaposlenik'))
@app.route('/zeljene_smjene', methods=['GET'])
def get_zeljene_smjene():
    return jsonify(stavljanje_vrijednosti('zeljene_smjene'))
# -----------------------------------------------------------------------------------------------------#

if __name__ == "__main__":
    app.run(debug=True)