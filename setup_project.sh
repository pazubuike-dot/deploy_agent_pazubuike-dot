#!/bin/bash

#Using the user's input to create a directory name
read -p "Enter your input: " user_input
mkdir -p "attendance_tracker_$user_input"
cd "attendance_tracker_$user_input"

#make the attendance.py file
cat > attendance_checker.py << 'EOF'
#!/bin/bash

import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports.log', f'reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('assets.csv', mode='r') as f, open('reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

chmod +x attendance_checker.py

#making the second file(helpers)
mkdir -p Helpers
cat > Helpers/assets.csv << 'EOF'
#!/bin/bash
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

chmod +x Helpers/assets.csv

#making the config file for json
cat > Helpers/config.json << 'EOF'
#!/bin/bash
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF
 chmod +x Helpers/config.json

#making report file
mkdir -p reports
cat > reports/reports.log << 'EOF'
#!/bin/bash
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

chmod +x reports/reports.log

echo "File structure setup successfully"



tree
