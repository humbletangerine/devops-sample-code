# Exercise 8 — Hello World Jenkins Job

## Objective
Create a shell script in a GitHub repository and configure Jenkins to execute it as a CI job.

## Files
- `hello-world.sh`: prints `Hello, Jenkins!`
- `Jenkinsfile`: Pipeline stage that checks out the repository through Jenkins Pipeline-from-SCM configuration and executes the script.

## Jenkins setup
1. Push this folder to your own GitHub repository.
2. In Jenkins, create a **Pipeline** item.
3. Set **Definition** to **Pipeline script from SCM** and select Git.
4. Supply your repository URL and branch `*/main`.
5. Set **Script Path** to `Exercise-8/Jenkinsfile` if this folder is at repository root. Adjust the path if you use another folder name.
6. Click **Build Now**, then inspect **Console Output** for `Hello, Jenkins!` and `Finished: SUCCESS`.

If the Pipeline plugin is unavailable, use a **Freestyle project** with Git SCM and an Execute shell build step:

```sh
sh Exercise-8/hello-world.sh
```

## Evidence
Capture a screenshot of **your own** Jenkins run showing `Hello, Jenkins!` and `Finished: SUCCESS`. The reference log supplied separately belongs to another user and is not proof of this project's execution.

## Expected result
Jenkins successfully checks out the repository and runs the shell script, printing `Hello, Jenkins!`.
