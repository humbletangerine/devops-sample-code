# Exercise 5: Docker Security with AppArmor and Python

## Aim
To understand Docker container security using AppArmor profiles and a Python Flask application.

## Tools Used
Docker Desktop, Python, Flask, AppArmor concepts, Windows PowerShell.

## Procedure
1. Created a Flask application.
2. Created a Dockerfile.
3. Built the Docker image flask-apparmor.
4. Ran the Flask application inside a Docker container.
5. Inspected Docker security options and the active AppArmor profile.
6. Created a sample custom AppArmor policy.

## Observation
Docker reported Seccomp and cgroup namespace security features.
AppArmor was not active in the current Docker Desktop environment.

## Result
The Flask container was built and tested successfully.
Custom AppArmor profile enforcement could not be demonstrated in this environment.
