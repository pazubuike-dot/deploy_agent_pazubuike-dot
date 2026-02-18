# deploy_agent_pazubuike-dot


Project Overview

The present project illustrates the idea of Infrastructure as Code (IaC) with the help of a Bash script that provides the automation of the deployment of a Student Attendance Tracker application.

Rather than creating directories and configuration files manually, the setup project script determines the entire workspace using the script setup project.sh, which guarantees:

- Reproducibility
- Efficiency
- Reliability



Directory Architecture

The script dynamically generated:

attendance_tracker_{user_input}/
│
├── attendance_checker.py
├── Helpers/
│ ├── assets.csv
│ └── config.json
└── reports/
└── reports.log


The value of the user input is offered at the runtime.


Features

1. Automated Project Factory
- develops the entire project outline.
- Produces all necessary source codes.
- Removes manual set up errors.

2. Dynamic Configuration (Stream Editing)
- reminds the user to update at will:
- Warning threshold (default: 75%)
- Failure threshold (default: 50%)
- In-place modification of config.json using sed.

3. Signal Processing (Process Management)
- Traps a signal (Ctrl+C)
- If interrupted:
- Archive the present project directory.
Deletes the directory which has not been finished.
- Keeps the workspace clean

4. Environment Health Check
- Checks whether python3 is installed.
- Visualize success or warning message.



How to Run

1. Clone the repository:

bash
git clone Deploying agent pazubuike-dot GitHub clone https://github.com/YOUR_USERNAME/deploy_agent_pazubuike-dot.git
cd deploy_agent_pazubuike-dot

2.Make the script executable

chmod +x setup_project.sh

3.Run the script 

./setup_project.sh



