from flask import Flask, request, jsonify
import joblib
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Load the models and necessary files
model = joblib.load('disease_model.pkl')
symptoms_list = joblib.load('symptoms_list.pkl')
num_to_disease = joblib.load('num_to_disease.pkl')

try:
    eye_model = joblib.load('eye_model.pkl')
except FileNotFoundError:
    eye_model = None
    print("Warning: eye_model.pkl not found. /predict_eye will not work until the model is trained.")


@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    input_symptoms = [s.strip().lower().replace(" ", "_") for s in data.get('symptoms', [])]

    # Create input vector
    input_vector = [1 if symptom in input_symptoms else 0 for symptom in symptoms_list]

    # Make prediction
    prediction = model.predict([input_vector])[0]
    predicted_disease = num_to_disease[prediction]

    return jsonify({'predicted_disease': predicted_disease})

@app.route('/predict_eye', methods=['POST'])
def predict_eye():
    if eye_model is None:
        return jsonify({'error': 'Eye model not loaded'}), 500
        
    data = request.json
    try:
        iop = float(data.get('IOP', 0))
        age = float(data.get('Age', 0))
        cdr = float(data.get('CDR', 0))
        
        # Make prediction (features: IOP, Age, CDR)
        prediction = eye_model.predict([[iop, age, cdr]])[0]
        
        # Optional: return probability as well
        prob = eye_model.predict_proba([[iop, age, cdr]])[0][1]
        
        result = "Glaucoma Detected" if prediction == 1 else "Normal"
        
        return jsonify({
            'prediction': result,
            'probability': f"{prob:.2f}",
            'risk_level': 'High' if prob > 0.65 else 'Moderate' if prob > 0.3 else 'Low'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)