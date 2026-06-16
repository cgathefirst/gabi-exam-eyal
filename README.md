# Examgabieyal CI/CD Pipeline

This repository hosts the continuous integration (CI) pipeline for the **examgabieyal** application. Built as a Jenkins Declarative/Scripted Hybrid Pipeline, it leverages dynamic Kubernetes agents to run builds securely, render Helm manifests, and push updates directly to a GitOps deployment repository (`gitops-argo`).

---

## 🛠️ Prerequisites & System Requirements

To run this pipeline successfully, your infrastructure must meet the following infrastructure and configuration requirements.

### 1. Kubernetes Cluster Requirements
* **Cluster Access:** A running Kubernetes cluster (v1.26+ recommended) with sufficient resources to provision dynamic agent pods.
* **RBAC Permissions:** The service account used by Jenkins inside the cluster must have permissions to create, list, watch, and delete pods in the target namespace.
* **Network Connectivity:** The cluster must have outbound internet access to pull the specified container images (`jenkins/inbound-agent`, `docker:26-dind`, and `alpine/helm`) and connect to GitHub/Docker Hub.

### 2. Jenkins Server Setup
* **Jenkins Installation:** A running Jenkins controller (v2.400+ recommended). It can run inside or outside the Kubernetes cluster.
  * *Recommended:* Deployed via the official Helm chart (`jenkinsci/jenkins`) directly into your Kubernetes cluster.
* **Required Jenkins Plugins:**
  * **Kubernetes Plugin:** Integrates Jenkins with Kubernetes to provision dynamic build agents.
  * **Pipeline Plugin:** Supports the execution of Groovy-based pipeline scripts.
  * **Active Choices Plugin:** Enables reactive, dynamic, and interactive user interface choice parameters during parameter input.
  * **Credentials Binding Plugin:** Enables secure injection of usernames/passwords (`withCredentials`).
  * **Git Plugin:** Handles repository checkouts via JNLP.

### 3. Kubernetes Cloud Provider Configuration
Before running the job, you must configure the Kubernetes cloud provider in Jenkins:
1. Navigate to **Manage Jenkins** ➡️ **Clouds** ➡️ **New Cloud** ➡️ **Kubernetes**.
2. Set the **Kubernetes URL** (e.g., `https://kubernetes.default.svc.cluster.local`).
3. Set the **Jenkins URL** so the dynamic agents can call back to the controller.
4. Ensure the name of the cloud matches `'kubernetes'` exactly, as defined in the script: `podTemplate(cloud: 'kubernetes', ...)`

---

## 🚀 Pipeline Overview

The pipeline executes entirely inside a Kubernetes cluster using dynamically provisioned multi-container pods (`jenkins/inbound-agent`, `docker:dind`, and `alpine/helm`). 

### Key Features
* **Multi-Container Pod Templates:** Runs jobs inside context-specific isolated containers.
* **Parallel Execution:** Performs code linting (Flake8) and vulnerability scanning (Trivy) simultaneously to optimize build times.(THIS STAGE IS STILL A MOCK)
* **GitOps Integration:** Generates a flat Kubernetes manifest using Helm templates and pushes it to a target GitOps repo for automated sync tools (like ArgoCD).

---

## 🎛️ Parameters

When triggering this pipeline manually in Jenkins ("Build with Parameters"), define the following settings:

| Parameter          | Type   | Default  | Description                                                                                          |
| :----------------- | :----- | :------- | :--------------------------------------------------------------------------------------------------- |
| `TARGET_SUBFOLDER` | Choice | `dev`    | Target deployment environment folder (`dev`, `qa`, `prod`). This value is also used as the Docker image tag. |
| `GIT_BRANCH`       | String | `second` | Target branch in the GitOps configuration repo to commit and push back into.                         |

---

## 📋 Pipeline Stages

1. **Checkout:** Clones the application source code using the standard JNLP agent.
2. **Security and Linting:** Runs two parallel jobs:
   * **Linting:** Validates Python style guides via Flake8.(MOCK STAGE)
   * **Security:** Runs Trivy container image and configuration scanning.(MOCK STAGE)
3. **Docker Build & Push:** Spins up a Docker-in-Docker (`dind`) sidecar, builds the application container image, authenticates securely against Docker Hub, and pushes the tagged image.
4. **Helm Template Validation:** Uses Helm v3 to render chart values locally, testing the generated template and writing it to a `pipeapp.yaml` file.
5. **Push Manifest to Git:** Clones the remote `cgathefirst/gitops-argo` repository, inserts/updates the output manifest into the environment-specific directory (`app1/k8s-{env}`), and commits/pushes changes conditionally if a diff is caught.

---

## 🔑 Required Jenkins Credentials

Configure the following credentials within your Jenkins credentials store:

* **`jenkins-dockcred`** (`Username with Password`): Docker Hub authentication token used to push the image to `docker.io/cgabya12/examgabieyal`.
* **`github-token-push`** (`Username with Password`): GitHub Personal Access Token (PAT) with write permissions to the `cgathefirst/gitops-argo` target repository.

---

## 📁 Repository Structure Expected by GitOps Stage

When pushing updates back to the GitOps repo, the pipeline dynamically targets the following directory hierarchy based on parameter variables:

```text
gitops-target-repo/ (branch: $GIT_BRANCH)
└── app1/
    ├── k8s-dev/
    │   └── pipeapp.yaml
    ├── k8s-qa/
    │   └── pipeapp.yaml
    └── k8s-prod/
        └── pipeapp.yaml
