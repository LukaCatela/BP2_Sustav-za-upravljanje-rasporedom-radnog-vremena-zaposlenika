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

@app.route('/zaposlenici', methods=['GET'])
def get_employees():
    with db.engine.connect() as conn:
        select_zapolsenik = text("SELECT * FROM zaposlenik")
        result = conn.execute(select_zapolsenik)
        zaposlenici = []
        for row in result: 
            zaposlenici.append({
                'id': row[0],
                'ime': row[1],
                'prezime': row[2],
                'email': row[3],
                'broj_telefona': row[4],
                'datum_zaposljavanja': row[5].strftime('%Y-%m-%d'),
                'pozicija': row[6],
                'status': row[7]
            })
    return Response(
        json.dumps(zaposlenici, ensure_ascii=False),
        mimetype='application/json; charset=utf-8'
    )

if __name__ == "__main__":
    app.run(debug=True)