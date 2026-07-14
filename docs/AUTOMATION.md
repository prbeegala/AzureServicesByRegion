# Automation

This repository ships a weekly GitHub Actions workflow that refreshes
`data/skus-by-region.json` and the shared `outputs/services-by-region/` and
`outputs/skus-by-region/` snapshots. Authentication is via **OIDC federated
identity** — the repo carries no long-lived secrets.

> **You do not need this to use the scripts.** Everything works locally with
> `az login`. This document is for maintainers who want the checked-in
> snapshots to stay current automatically.

## What the workflow does

`.github/workflows/refresh-snapshots.yml`

- Runs on **Mondays 03:00 UTC** (`0 3 * * 1`), plus on-demand via
  `workflow_dispatch`.
- Logs in to Azure with OIDC (no client secret, no PAT).
- Runs `Get-AzureSkusByRegion.ps1` — refreshes `data/skus-by-region.json`
  and the Markdown/CSV samples under `outputs/skus-by-region/<geo>/`.
- Runs `Get-AzureServicesByRegion.ps1` across the six mainstream
  geography groups — refreshes `outputs/services-by-region/<geo>/`.
- If `git status` shows anything under `data/` or `outputs/` has changed,
  commits the diff and pushes back to the same branch (typically `main`).
- Publishes a job summary showing what changed.

The workflow does **not** refresh:

- `outputs/coverage/<region>/` — driven by a real Resource Graph inventory
  from your subscription; refresh with `./Compare-AzureRegionCoverage.ps1`.
- `outputs/scorecard/<region>/` — same reason; refresh with
  `./Score-AzureRegionFit.ps1`.
- `data/latency-baseline.json` and `data/egress-rates.json` — currently
  refreshed manually (see [`data/README.md`](../data/README.md)).

## One-time setup (repo owner)

You need an Azure identity that GitHub Actions can log in as. **Reader on a
tiny sandbox subscription is sufficient** — all endpoints touched are
metadata-only.

### 1. Create a user-assigned managed identity

```bash
az group create --name gh-actions-sbr --location uksouth

az identity create \
  --resource-group gh-actions-sbr \
  --name github-azureservicesbyregion
```

Capture the identity's `clientId`, `principalId` and the sub's `id` and
`tenantId`:

```bash
CLIENT_ID=$(az identity show -g gh-actions-sbr -n github-azureservicesbyregion --query clientId -o tsv)
PRINCIPAL_ID=$(az identity show -g gh-actions-sbr -n github-azureservicesbyregion --query principalId -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
SUB_ID=$(az account show --query id -o tsv)

echo "CLIENT_ID=$CLIENT_ID"
echo "TENANT_ID=$TENANT_ID"
echo "SUB_ID=$SUB_ID"
```

### 2. Grant Reader on the sandbox subscription

```bash
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role Reader \
  --scope "/subscriptions/$SUB_ID"
```

### 3. Create the federated credential

Two credentials are recommended — one for `main`, one for pull requests, so
the workflow can `workflow_dispatch` from any branch during development.

```bash
# main branch (scheduled runs, real commits)
az identity federated-credential create \
  --name gh-main \
  --identity-name github-azureservicesbyregion \
  --resource-group gh-actions-sbr \
  --issuer https://token.actions.githubusercontent.com \
  --subject 'repo:prbeegala/AzureServicesByRegion:ref:refs/heads/main' \
  --audiences api://AzureADTokenExchange

# any pull request (dry-run only — commit step is gated by branch)
az identity federated-credential create \
  --name gh-pull-request \
  --identity-name github-azureservicesbyregion \
  --resource-group gh-actions-sbr \
  --issuer https://token.actions.githubusercontent.com \
  --subject 'repo:prbeegala/AzureServicesByRegion:pull_request' \
  --audiences api://AzureADTokenExchange
```

### 4. Set the repo variables

The workflow reads three **variables** (not secrets — none of these values
are sensitive; the client id and tenant id are already discoverable, and
Reader-scoped principals cannot exfiltrate data):

- **Settings → Secrets and variables → Actions → Variables**
- Add:
  - `AZURE_CLIENT_ID`      = `$CLIENT_ID`
  - `AZURE_TENANT_ID`      = `$TENANT_ID`
  - `AZURE_SUBSCRIPTION_ID` = `$SUB_ID`

## Testing the workflow

### Local dry-run

```powershell
# Every step the workflow runs can be executed locally:
./Get-AzureSkusByRegion.ps1 -GeographyGroup Europe
./Get-AzureServicesByRegion.ps1 -GeographyGroup Europe
```

### Manual GitHub Actions dispatch

```bash
gh workflow run refresh-snapshots.yml
gh run watch
```

Or via the UI: **Actions → Refresh snapshots → Run workflow**.

### First scheduled run

Once the workflow has completed at least one manual run successfully, the
Monday 03:00 UTC schedule takes over. Watch **Actions → Refresh
snapshots** for the next few weeks to confirm the commits are landing.

## Troubleshooting

### `AADSTS70021: No matching federated identity record found`

The `subject` on the federated credential must match exactly what the
Actions token presents. For scheduled runs on `main`:
`repo:prbeegala/AzureServicesByRegion:ref:refs/heads/main`. For a PR from
a fork, GitHub uses `repo:<upstream>:pull_request` — that's why the second
federated credential above uses that shape.

### `AuthorizationFailed` on the sub

The Reader role assignment on the sub is a prerequisite. Verify with:

```bash
az role assignment list \
  --assignee "$PRINCIPAL_ID" \
  --scope "/subscriptions/$SUB_ID" \
  --output table
```

### `az rest ... 429 Too Many Requests`

The full 11-provider Tier 1 run makes ~180 `az rest` calls (well inside
ARM's default 12,000 req/hour). If you hit 429s regardless, the built-in
retry-with-exponential-backoff (up to 4 attempts, up to 30 s sleep) should
absorb it. If not, split the run across two workflow jobs (`-Provider
Microsoft.Compute` alone, then the rest).

### The commit step didn't push

The workflow only commits if `git diff --quiet` says something changed
under `data/` or `outputs/`. If Azure hasn't shipped any new SKUs or
regions since last week, there's nothing to commit — that's the expected
no-op case. Check the job summary for the `git diff --stat` output.

## Sovereign / national clouds

The workflow targets Azure Commercial only. To refresh snapshots for
Azure US Government or Azure China 21Vianet, mirror the setup above into
a separate identity in that cloud, and add a matching workflow that runs
`az cloud set --name AzureUSGovernment` (or `AzureChinaCloud`) before the
`azure/login` step. Left as future work.
