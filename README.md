# Salesforce DevOps Pipeline

A CI/CD pipeline that automates Salesforce metadata deployments using GitHub Actions, Salesforce DX, and PMD static analysis. On every push to `main`, the pipeline runs static analysis, provisions a scratch org, deploys Apex classes, runs the full test suite, and tears the org down — zero manual steps required.

---

## Pipeline Overview

```
Push to main
     │
     ▼
┌─────────────────────┐
│  PMD Static Analysis │  ← Blocks on violations
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  Create Scratch Org  │  ← Ephemeral, 1-day lifespan
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  Deploy Metadata     │  ← Apex classes via SFDX CLI
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  Run Apex Tests      │  ← Enforces code coverage gate
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  Delete Scratch Org  │  ← Always runs, even on failure
└─────────────────────┘
```

---

## Tech Stack

| Tool | Purpose |
|---|---|
| GitHub Actions | CI/CD orchestration |
| Salesforce DX (SFDX) | Scratch org provisioning and metadata deployment |
| Salesforce CLI | Apex test execution and org management |
| PMD | Static code analysis (best practices + error prone rules) |
| GitHub Encrypted Secrets | Secure Dev Hub authentication |

---

## Project Structure

```
salesforce-devops-showcase/
├── .github/
│   └── workflows/
│       └── deploy.yml              # CI/CD pipeline definition
├── config/
│   └── project-scratch-def.json    # Scratch org configuration
├── force-app/
│   └── main/
│       └── default/
│           └── classes/
│               ├── StringUtils.cls             # Apex utility class
│               ├── StringUtils.cls-meta.xml
│               ├── StringUtilsTest.cls         # Apex test class
│               └── StringUtilsTest.cls-meta.xml
├── pmd-ruleset.xml                 # Custom PMD ruleset
└── sfdx-project.json               # SFDX project config
```

---

## Getting Started

### Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) installed
- A [Salesforce Developer Edition org](https://developer.salesforce.com/signup) with Dev Hub enabled
- A GitHub account

### 1. Clone the repo

```bash
git clone https://github.com/Mo-Tar/salesforce-devops-showcase
cd salesforce-devops-showcase
```

### 2. Authorize your Dev Hub

```bash
sf org login web --set-default-dev-hub --alias DevHub
```

### 3. Add the GitHub Secret

Get your Dev Hub auth URL:

```bash
sf org display --target-org DevHub --verbose
# Copy the "Sfdx Auth Url" value
```

In your GitHub repo: **Settings → Secrets and variables → Actions → New repository secret**

| Name | Value |
|---|---|
| `SFDX_AUTH_URL` | Your Sfdx Auth Url from above |

### 4. Push to trigger the pipeline

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

The Actions tab will show all stages running. A green checkmark means the deploy and tests passed.

---

## Running Locally

**Create a scratch org manually:**
```bash
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias MyScratchOrg \
  --set-default \
  --duration-days 1
```

**Deploy metadata:**
```bash
sf project deploy start --source-dir force-app --target-org MyScratchOrg
```

**Run Apex tests:**
```bash
sf apex run test \
  --target-org MyScratchOrg \
  --wait 10 \
  --result-format human \
  --code-coverage
```

**Run PMD locally:**
```bash
~/pmd/bin/pmd check \
  --dir force-app/main/default/classes \
  --rulesets pmd-ruleset.xml \
  --format text
```

**Delete the scratch org when done:**
```bash
sf org delete scratch --target-org MyScratchOrg --no-prompt
```

---

## What's Deployed

### `StringUtils.cls`

A simple Apex utility class with two methods used to demonstrate deployment and test coverage:

- `capitalize(String input)` — Capitalizes the first character of a string
- `isPalindrome(String input)` — Returns true if the cleaned input reads the same forwards and backwards

### `StringUtilsTest.cls`

Apex test class covering both methods, used to enforce the code coverage gate in the pipeline.

---

## Key Design Decisions

**Ephemeral scratch orgs** — A fresh org is created per pipeline run and deleted on completion, ensuring deployments are always tested against a clean environment with no state bleed between runs.

**PMD gates the pipeline** — Static analysis runs before any deployment attempt. Violations in the `bestpractices` or `errorprone` rulesets block the pipeline entirely.

**Secrets over hardcoded credentials** — Dev Hub authentication uses GitHub Encrypted Secrets so no credentials ever touch source control.

**Always-on cleanup** — The scratch org deletion step runs with `if: always()`, meaning the org is removed even if deployment or tests fail.

---

## Author

**Muhammad Tarar**
[LinkedIn](https://linkedin.com/in/muhammad-tararr) · [GitHub](https://github.com/Mo-Tar)
