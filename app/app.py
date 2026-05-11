from flask import Flask, jsonify
import json, random, datetime

app = Flask(__name__)

# Simulated analytics data (in production this reads from BigQuery)
EVENTS_DATA = [
    {"event_id": 1, "event_name": "Tech Symposium 2025",  "registrations": 3, "views": 5},
    {"event_id": 2, "event_name": "Annual Sports Day",     "registrations": 2, "views": 3},
    {"event_id": 3, "event_name": "Cultural Fest",         "registrations": 1, "views": 2},
    {"event_id": 4, "event_name": "Hackathon 2025",        "registrations": 3, "views": 4},
    {"event_id": 5, "event_name": "Alumni Gala",           "registrations": 1, "views": 2},
    {"event_id": 6, "event_name": "Science Fair",          "registrations": 0, "views": 1},
]

@app.route('/')
def home():
    return jsonify({"service": "UniEvent Analytics API", "version": "1.0", "status": "running"})

@app.route('/api/popular-events')
def popular_events():
    sorted_events = sorted(EVENTS_DATA, key=lambda x: x['registrations'], reverse=True)
    return jsonify({"data": sorted_events, "generated_at": str(datetime.datetime.now())})

@app.route('/api/stats')
def stats():
    return jsonify({
        "total_events": len(EVENTS_DATA),
        "total_registrations": sum(e['registrations'] for e in EVENTS_DATA),
        "total_views": sum(e['views'] for e in EVENTS_DATA),
        "most_popular": max(EVENTS_DATA, key=lambda x: x['registrations'])['event_name']
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOF
