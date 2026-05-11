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
