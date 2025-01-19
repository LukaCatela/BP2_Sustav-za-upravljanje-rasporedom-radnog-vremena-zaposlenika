from flask import Flask, render_template, request, redirect, url_for, session, jsonify
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

app = Flask(__name__, template_folder='templates', static_folder='static')
app.secret_key = 'secret_key'

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:luka23012005@db:3306/bp_2_projekt'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

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

    # Default to Marko Jurić's data
    schedule = []
    try:
        with db.engine.connect() as conn:
            result = conn.execute(
                text("""
                     SELECT 
                     r.datum, 
                     vs.naziv AS raspored,
                     n.napomena AS napomena
                     FROM raspored_rada r
                     LEFT JOIN smjene s ON r.id_smjena = s.id
                     LEFT JOIN vrsta_smjene vs ON s.id_vrsta_smjene = vs.id
                     LEFT JOIN napomene n ON r.id_zaposlenik = n.id_zaposlenik AND r.datum = n.datum
                     WHERE r.id_zaposlenik = (SELECT id FROM zaposlenik WHERE ime = 'Marko' AND prezime = 'Jurić')
                """)
            )
            schedule = [dict(row._mapping) for row in result]
    except Exception as e:
        return render_template('index.html', is_admin=False, schedule=[], message=f"Error fetching schedule: {e}")


    return render_template('index.html', is_admin=False, schedule=schedule, message=None)

@app.route('/procedure', methods=['GET', 'POST'])
def procedure():
    if request.method == 'POST':
        data = request.json
        try:
            with db.engine.connect() as conn:
                conn.execute(
                    text("CALL dodaj_zaposlenika(:p_ime, :p_prezime, :p_oib, :p_spol, :p_email, :p_broj_telefona, :p_datum_zaposljavanja, :p_pozicija, :p_status_zaposlenika, :p_satnica, :p_id_odjel)"),
                    {
                        'p_ime': data['ime'],
                        'p_prezime': data['prezime'],
                        'p_oib': data['oib'],
                        'p_spol': data['spol'],
                        'p_email': data['email'],
                        'p_broj_telefona': data['broj_telefona'],
                        'p_datum_zaposljavanja': data['datum_zaposljavanja'],
                        'p_pozicija': data['pozicija'],
                        'p_status_zaposlenika': data['status_zaposlenika'],
                        'p_satnica': data['satnica'],
                        'p_id_odjel': data['id_odjel']
                    }
                )
            return jsonify({"message": "Procedure executed successfully!"}), 200
        except Exception as e:
            return jsonify({"error": str(e)}), 500

    return render_template('dodaj_zaposlenika.html')

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

@app.route('/test-procedure')
def test_procedure():
    # Call the procedure with some test data and return the result
    try:
        with db.engine.connect() as conn:
            conn.execute(
                text("CALL dodaj_zaposlenika(:p_ime, :p_prezime, :p_oib, :p_spol, :p_email, :p_broj_telefona, :p_datum_zaposljavanja, :p_pozicija, :p_status_zaposlenika, :p_satnica, :p_id_odjel)"),
                {
                    'p_ime': 'Test',
                    'p_prezime': 'User',
                    'p_oib': '12345678901',
                    'p_spol': 'M',
                    'p_email': 'testuser@example.com',
                    'p_broj_telefona': '0912345678',
                    'p_datum_zaposljavanja': '2025-01-20',
                    'p_pozicija': 'Test Position',
                    'p_status_zaposlenika': 'aktivan',
                    'p_satnica': 50.00,
                    'p_id_odjel': 1
                }
            )
        return jsonify({"message": "Test procedure executed successfully!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)