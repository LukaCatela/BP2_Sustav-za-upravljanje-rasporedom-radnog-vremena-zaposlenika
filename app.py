from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

app = Flask(__name__, template_folder='templates', static_folder='static')

# Konfiguracija baze
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:luka23012005@db:3306/bp_2_projekt'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

@app.route('/')
def index():
    return render_template('index.html', table_data=None, message="Odaberite tablicu za prikaz podataka.")

# Pomocna Funkcija
def stavljanje_vrijednosti(ime_tablice):
    try:
        with db.engine.connect() as conn:
            query = text(f"SELECT * FROM {ime_tablice}")
            result = conn.execute(query)
            data = [dict(row._mapping) for row in result]
            if not data:
                return {"status": "empty", "data": None}
            return {"status": "success", "data": data}
    except Exception as e:
        print(f"Error fetching data from {ime_tablice}: {e}")
        return {"status": "error", "data": None}

# Svi routeovi koji koriste pomocnu funkciju
@app.route('/zaposlenik', methods=['GET'])
def get_zaposlenik():
    return table_view('zaposlenik')

@app.route('/bolovanje', methods=['GET'])
def get_bolovanje():
    return table_view('bolovanje')

@app.route('/dopust', methods=['GET'])
def get_dopust():
    return table_view('dopust')

@app.route('/evidencija_rada', methods=['GET'])
def get_evidencija_rada():
    return table_view('evidencija_rada')

@app.route('/godisnji_odmori', methods=['GET'])
def get_godisnji_odmori():
    return table_view('godisnji_odmori')

@app.route('/napomene', methods=['GET'])
def get_napomene():
    return table_view('napomene')

@app.route('/odjel', methods=['GET'])
def get_odjel():
    return table_view('odjel')

@app.route('/place', methods=['GET'])
def get_place():
    return table_view('place')

@app.route('/preferencije_smjena', methods=['GET'])
def get_preferencije_smjena():
    return table_view('preferencije_smjena')

@app.route('/projekti', methods=['GET'])
def get_projekti():
    return table_view('projekti')

@app.route('/raspored_rada', methods=['GET'])
def get_raspored_rada():
    return table_view('raspored_rada')

@app.route('/sluzbena_putovanja', methods=['GET'])
def get_sluzbena_putovanja():
    return table_view('sluzbena_putovanja')

@app.route('/smjene', methods=['GET'])
def get_smjene():
    return table_view('smjene')

@app.route('/vrsta_smjene', methods=['GET'])
def get_vrsta_smjene():
    return table_view('vrsta_smjene')

@app.route('/zadaci', methods=['GET'])
def get_zadaci():
    return table_view('zadaci')

@app.route('/zahtjev_prekovremeni', methods=['GET'])
def get_zahtjev_prekovremeni():
    return table_view('zahtjev_prekovremeni')
@app.route('/test-connection')
def test_connection():
    try:
        with db.engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return "Database connection successful!"
    except Exception as e:
        return f"Database connection failed: {e}"


if __name__ == "__main__":
    app.run(debug=True)
