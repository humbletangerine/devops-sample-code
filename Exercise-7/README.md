# Exercise 7 — Jenkins CI Automation

## Aim
Install Jenkins with Docker and understand automated CI jobs.

## Docker setup
`docker ps --filter ancestor=jenkins/jenkins:lts` verifies the existing container. Jenkins runs locally at http://localhost:8080.

## Demo job
Create a Jenkins Freestyle project using **Execute shell**, and paste:

```sh
echo 'Build: preparing application'
echo 'Test: basic checks passed'
echo 'Deploy: simulated deployment only'
```

If the Pipeline plugin is installed, create a Pipeline job with the included `Jenkinsfile` instead. These stages demonstrate the workflow; they do not perform a real deployment.

## Evidence
Save actual Jenkins screenshots / console logs only after running the job. The submitted source files alone do not establish a successful Jenkins build.
