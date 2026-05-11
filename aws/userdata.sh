cat << 'EOF' > userdata.sh
#!/bin/bash
yum update -y
yum install -y python3 python3-pip
pip3 install flask boto3 requests

mkdir -p /app
cat << 'PYEOF' > /app/app.py
from flask import Flask, render_template_string, jsonify
import requests, boto3, os

app = Flask(__name__)
BUCKET = os.environ.get('S3_BUCKET', 'your-bucket-name')

TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
  <title>UniEvent Pro</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f0f2f5; }
    h1 { color: #333; text-align: center; }
    .grid { display: flex; flex-wrap: wrap; gap: 20px; justify-content: center; }
    .card { background: white; border-radius: 12px; padding: 20px; width: 280px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
    .card h3 { margin: 0 0 8px; color: #1a1a2e; }
    .card p  { color: #555; font-size: 14px; }
    .badge   { background: #e0e7ff; color: #3730a3; padding: 2px 8px;
               border-radius: 20px; font-size: 12px; }
    .btn     { background: #4f46e5; color: white; border: none; padding: 8px 16px;
               border-radius: 8px; cursor: pointer; margin-top: 10px; }
    .footer  { text-align: center; margin-top: 40px; color: #888; font-size: 12px; }
  </style>
</head>
<body>
  <h1>🎓 UniEvent Pro</h1>
  <p style="text-align:center;color:#666">Browse and register for upcoming university events</p>
  <div class="grid">
    {% for event in events %}
    <div class="card">
      <span class="badge">{{ event.genre }}</span>
      <h3>{{ event.name }}</h3>
      <p>📅 {{ event.date }}</p>
      <p>📍 {{ event.venue }}</p>
      <button class="btn" onclick="register('{{ event.id }}')">Register</button>
    </div>
    {% endfor %}
  </div>
  <div class="footer">Powered by UniEvent Pro | AWS + GCP Cloud Architecture</div>
  <script>
    function register(id) {
      fetch('/register/' + id, {method:'POST'})
        .then(r => r.json())
        .then(d => alert(d.message));
    }
  </script>
</body>
</html>
"""

@app.route('/')
def index():
    events = get_events()
    return render_template_string(TEMPLATE, events=events)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'instance': os.popen('curl -s http://169.254.169.254/latest/meta-data/instance-id').read()})

@app.route('/register/<event_id>', methods=['POST'])
def register(event_id):
    return jsonify({'message': f'Successfully registered for event {event_id}!'})

def get_events():
    try:
        url = "https://app.ticketmaster.com/discovery/v2/events.json"
        params = {'apikey': 'YOUR_TICKETMASTER_KEY', 'keyword': 'university', 'size': 6}
        r = requests.get(url, params=params, timeout=5)
        items = r.json().get('_embedded', {}).get('events', [])
        return [{'id': e['id'], 'name': e['name'],
                 'date': e['dates']['start'].get('localDate','TBD'),
                 'venue': e['_embedded']['venues'][0]['name'] if '_embedded' in e else 'TBD',
                 'genre': e['classifications'][0]['genre']['name'] if e.get('classifications') else 'General'}
                for e in items]
    except:
        return [
            {'id':'1','name':'Tech Symposium 2025','date':'2025-06-15','venue':'Main Auditorium','genre':'Technology'},
            {'id':'2','name':'Annual Sports Day','date':'2025-06-20','venue':'University Grounds','genre':'Sports'},
            {'id':'3','name':'Cultural Fest','date':'2025-06-25','venue':'Arts Complex','genre':'Arts'},
            {'id':'4','name':'Hackathon 2025','date':'2025-07-01','venue':'CS Building','genre':'Technology'},
            {'id':'5','name':'Alumni Gala','date':'2025-07-10','venue':'Conference Hall','genre':'Networking'},
            {'id':'6','name':'Science Fair','date':'2025-07-15','venue':'Science Block','genre':'Academic'},
        ]

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
PYEOF

python3 /app/app.py &
EOF
