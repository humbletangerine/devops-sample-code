# Exercise 9: Jenkins Multi-Stage Pipeline

## Objective
Build, test, and mock-deploy a Flask application through Jenkins stages.

## Files
- `app.py`: Flask application
- `requirements.txt`: Python dependencies
- `test_app.py`: unit test
- `Jenkinsfile`: Build, Test, Deploy, Test Deployed Application stages

## Setup
Jenkins agent must have Python 3, python3-venv, and pip available. Install these in the Jenkins container as root (Debian-based image):

```bash
apt-get update && apt-get install -y python3 python3-venv python3-pip
```

For Jenkins 'Pipeline script from SCM', repository must place these four files in the same folder, and Script Path must point to that folder's `Jenkinsfile`. Alternatively paste the Jenkinsfile into a Pipeline script job with matching Git checkout.

## Expected Result
A successfully executed pipeline should show unit tests passing and mock deployment files copied. Do not claim success until your Jenkins build finishes with SUCCESS.
