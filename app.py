from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy 

app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:luka23012005@127.0.0.1:3306/bp_2_projekt'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

@app.route('/')
def index():
    return "Spojeno je pedercine!" 

@app.route('/zaposlenici', methods=['GET'])
def get_employees():
    result = db.engine.execute("SELECT * FROM zaposlenik")
    zaposlenici = []
    for row in result:
        zaposlenici.append({
            'id': row['id'],
            'ime': row['ime'],
            'prezime': row['prezime'],
            'email': row['email'],
            'broj_telefona': row['broj_telefona'],
            'datum_zaposljavanja': row['datum_zaposljavanja'].strftime('%Y-%m-%d'),  # Format date
            'pozicija': row['pozicija'],
            'status': row['status']
        })
    return jsonify(zaposlenici)

if __name__ == "__main__":
    app.run(debug=True)
