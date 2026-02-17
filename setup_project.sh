#!/bin/bash


#Using the user's input to create a directory name
read -p "Enter your input: " user_input

signal_trap() {
    echo "===================================="
    echo "Script interrupted. archiving ..."
    archive="attendance_tracker_${user_input}_archive"
    if [ -d "$dir" ]; then
    	tar czf "${archive}.tar.gz" "$dir"
    	rm -rf "$dir"
    fi

    echo "Directory is archived"
    exit 1
}
trap 'signal_trap' SIGINT

dir="attendance_tracker_$user_input"

sleep 0.7
mkdir -p "$dir"

#make the attendance.py file
cat > $dir/attendance_checker.py << 'EOF'

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



#making the second file(helpers)
sleep 0.7
mkdir -p $dir/Helpers
cat > $dir/Helpers/assets.csv << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF


#making the config file for json
cat > $dir/Helpers/config.json << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}

EOF

echo "------------------------------------------------------"
echo "Update Warning/ Faliure threshold?"
echo "------------------------------------------------------"
while true; do
    read -p "Do you want to update warning threshold? (yes/no): " responseA
    if [ "$responseA" = "yes" ]; then
        read -p "Enter new warning threshold: " warn
        sed -i "s/\"warning\": 75/\"warning\": $warn/" "$dir/Helpers/config.json"
        sleep 0.4
        echo "Warning threshold changed to $warn"
        break
    elif [ "$responseA" = "no" ]; then
        echo "continuing ..."
        break
    else
        echo "Invalid response. Please enter yes or no"
    fi
done


while true; do
    echo ""
    read -p "Do you want to update failure threshold? (yes/no): " responseB
    if [ "$responseB" = "yes" ]; then
        read -p "Enter new failure threshold: " fail
        sed -i "s/\"failure\": 50/\"failure\": $fail/" "$dir/Helpers/config.json"
        sleep 0.4
	echo ""
        echo "Failure threshold changed to $fail"
        break
    elif [ "$responseB" = "no" ]; then
	echo "continuing ..."
        break
    else
        echo "Invalid response. Please enter yes or no."
    fi
done
echo "----------------------------------------------------------"


#making report file
sleep 0.7
mkdir -p $dir/reports
cat > $dir/reports/reports.log << 'EOF'

--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF


py_version=$(python3 --version 2>&1)


echo "=============================="
echo "Python3 Verification:"
if [ $? -ne 0 ]; then
    echo "python3: command not found"
else
    echo "Success! python3 present"
fi 
echo "=============================="

tree ./$dir
