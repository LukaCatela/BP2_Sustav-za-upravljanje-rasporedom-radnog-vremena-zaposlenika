from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

app = Flask(__name__, template_folder='templates', static_folder='static')
app.secret_key = 'secret_key'

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:luka23012005@db:3306/bp_2_projekt'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)


### ------------------- GENERAL ROUTES -------------------
@app.route('/')
def index():
    if 'admin' in session and session['admin']:
        users = []
        try:
            with db.engine.connect() as conn:
                result = conn.execute(text("SELECT id, ime, prezime FROM zaposlenik"))
                users = [dict(row._mapping) for row in result]
        except Exception as e:
            return render_template('index.html', is_admin=True, users=[], message=f"Error fetching users: {e}")
        return render_template('index.html', is_admin=True, users=users, message=None)

    schedule = []
    try:
        with db.engine.connect() as conn:
            result = conn.execute(text("""
                SELECT r.datum, vs.naziv AS raspored, n.napomena AS napomena
                FROM raspored_rada r
                LEFT JOIN smjene s ON r.id_smjena = s.id
                LEFT JOIN vrsta_smjene vs ON s.id_vrsta_smjene = vs.id
                LEFT JOIN napomene n ON r.id_zaposlenik = n.id_zaposlenik AND r.datum = n.datum
                WHERE r.id_zaposlenik = (SELECT id FROM zaposlenik WHERE ime = 'Marko' AND prezime = 'Jurić')
            """))
            schedule = [dict(row._mapping) for row in result]
    except Exception as e:
        return render_template('index.html', is_admin=False, schedule=[], message=f"Error fetching schedule: {e}")

    return render_template('index.html', is_admin=False, schedule=schedule, message=None)


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        try:
            with db.engine.connect() as conn:
                query = text(
                    "SELECT 1 FROM mysql.user WHERE user = :username AND host = 'localhost'"
                )
                result = conn.execute(query, {'username': username})
                if result.fetchone():
                    session['admin'] = True
                    return redirect(url_for('index'))
        except Exception as e:
            return render_template('login.html', error=f"Login failed: {e}")

        return render_template('login.html', error="Invalid username or password.")

    return render_template('login.html', error=None)


@app.route('/logout')
def logout():
    session.pop('admin', None)
    return redirect(url_for('index'))


@app.route('/schedule/<int:user_id>')
def get_schedule(user_id):
    schedule = []
    try:
        with db.engine.connect() as conn:
            query = text("""
                SELECT 
                    r.datum AS datum, 
                    vs.naziv AS raspored, 
                    n.napomena AS napomena
                FROM raspored_rada r
                LEFT JOIN smjene s ON r.id_smjena = s.id
                LEFT JOIN vrsta_smjene vs ON s.id_vrsta_smjene = vs.id
                LEFT JOIN napomene n ON r.id_zaposlenik = n.id_zaposlenik AND r.datum = n.datum
                WHERE r.id_zaposlenik = :user_id
            """)
            result = conn.execute(query, {'user_id': user_id})
            schedule = [dict(row._mapping) for row in result]
    except Exception as e:
        return jsonify({"error": f"Error fetching schedule: {e}"}), 500

    return jsonify(schedule)


### ------------------- EMPLOYEE MANAGEMENT -------------------
@app.route('/dodaj_zaposlenika', methods=['POST'])
def dodaj_zaposlenika():
    data = request.json
    try:
        with db.engine.connect() as conn:
            conn.execute(text("""
                CALL dodaj_zaposlenika(:p_ime, :p_prezime, :p_oib, :p_spol, :p_email, :p_broj_telefona, 
                                       :p_datum_zaposljavanja, :p_pozicija, :p_status_zaposlenika, :p_satnica, :p_id_odjel)
            """), data)
        return jsonify({"message": "Zaposlenik dodan uspješno!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/brisi_zaposlenika/<int:zaposlenik_id>', methods=['DELETE'])
def brisi_zaposlenika(zaposlenik_id):
    try:
        with db.engine.connect() as conn:
            conn.execute(text("CALL brisi_zaposlenika(:zaposlenik_id)"), {'zaposlenik_id': zaposlenik_id})
        return jsonify({"message": "Zaposlenik obrisan!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


### ------------------- PROJECT MANAGEMENT -------------------
@app.route('/dodaj_projekt', methods=['POST'])
def dodaj_projekt():
    data = request.json
    try:
        with db.engine.connect() as conn:
            conn.execute(text("""
                CALL dodaj_projekt(:naziv, :opis, :datum_pocetka, :datum_zavrsetka, :status, :odgovorna_osoba)
            """), data)
        return jsonify({"message": "Projekt dodan!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/prijenos_projekta', methods=['POST'])
def prijenos_projekta():
    data = request.json
    try:
        with db.engine.connect() as conn:
            conn.execute(text("CALL prijenos_projekta_drugom_zaposleniku(:projekt_id, :novi_zap_id)"), data)
        return jsonify({"message": "Projekt prenesen!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


### ------------------- SCHEDULE MANAGEMENT -------------------

@app.route('/prikaz_smjena', methods=['GET'])
def prikaz_smjena():
    datum = request.args.get("datum")
    try:
        with db.engine.connect() as conn:
            result = conn.execute(text("CALL prikaz_smjene_zaposlenika(:datum)"), {'datum': datum})
            return jsonify([dict(row._mapping) for row in result])
    except Exception as e:
        return jsonify({"error": str(e)}), 500


### ------------------- OVERTIME & LEAVE MANAGEMENT -------------------
@app.route('/odobri_prekovremeni', methods=['POST'])
def odobri_prekovremeni():
    data = request.json
    try:
        with db.engine.connect() as conn:
            conn.execute(text("CALL DodajPrekovremeneSate(:id_zahtjev)"), data)
        return jsonify({"message": "Prekovremeni sati dodani!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/odobri_godisnji', methods=['POST'])
def odobri_godisnji():
    try:
        with db.engine.connect() as conn:
            conn.execute(text("CALL odobrigodisnji()"))
        return jsonify({"message": "Godišnji odmori odobreni!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/korisnik_prihvaca_godisnji', methods=['POST'])
def korisnik_prihvaca_godisnji():
    data = request.json
    try:
        with db.engine.connect() as conn:
            conn.execute(text("CALL korisnikPrihvacaGodisnji(:status_prihvacanja, :id_godisnji)"), data)
        return jsonify({"message": "Status godišnjeg odmora ažuriran!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


### ------------------- REPORTS & VIEWS -------------------
@app.route('/mjesecna_placa/<int:zaposlenik_id>', methods=['GET'])
def mjesecna_placa(zaposlenik_id):
    try:
        with db.engine.connect() as conn:
            result = conn.execute(text("SELECT mjesecnaPlaca(:zaposlenik_id) AS placa"),
                                  {'zaposlenik_id': zaposlenik_id})
            return jsonify({"mjesecna_placa": result.fetchone()[0]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/ukupni_troskovi', methods=['GET'])
def ukupni_troskovi():
    mjesec = request.args.get("mjesec")
    try:
        with db.engine.connect() as conn:
            result = conn.execute(text("CALL UkupniIzvjestajTroskovaMjesec(:mjesec)"), {'mjesec': mjesec})
            return jsonify([dict(row._mapping) for row in result])
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/api/raspored')
def api_raspored():
    try:
        with db.engine.connect() as conn:
            result = conn.execute(text("""
                SELECT 
                    r.id_zaposlenik, 
                    z.ime, 
                    z.prezime, 
                    r.datum, 
                    vs.naziv AS raspored
                FROM raspored_rada r
                JOIN zaposlenik z ON r.id_zaposlenik = z.id
                LEFT JOIN smjene s ON r.id_smjena = s.id
                LEFT JOIN vrsta_smjene vs ON s.id_vrsta_smjene = vs.id
                ORDER BY r.id_zaposlenik, r.datum
            """))
            schedule = [dict(row._mapping) for row in result]
        return jsonify(schedule)  # Must return an array
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/raspored')
def raspored():
    return render_template('raspored.html')


if __name__ == '__main__':
    app.run(debug=True)
