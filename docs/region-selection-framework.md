# Region Selection Framework

> A checklist for choosing an Azure region when your current hub is
> constrained, when you're standing up a new workload, or when you're planning
> multi-region growth. Every criterion below is grounded in Microsoft's
> official FY26 region-selection guidance (regional compliance, service
> availability, AZ support, capacity, latency) and extended with the
> operational dimensions that surface once an enterprise actually tries to
> move a workload — SKU portability, quota freezes, capacity-guarantee
> mechanisms, egress economics, replication topology, and sovereignty tiers.
>
> **This document is a checklist, not a decision.** The stack-rank comes from
> [`Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1), which turns the
> criteria below into a per-region scorecard. Read this doc first so the
> ranking is explainable; run the tool second to make it repeatable.

---

## Table of contents

- [1. When to use this framework](#1-when-to-use-this-framework)
- [2. Microsoft's five pillars](#2-microsofts-five-pillars)
- [3. Extended enterprise dimensions](#3-extended-enterprise-dimensions)
- [4. Hard filters vs soft factors](#4-hard-filters-vs-soft-factors)
- [5. Mapping to the Well-Architected Framework](#5-mapping-to-the-well-architected-framework)
- [6. Full criterion catalogue](#6-full-criterion-catalogue)
- [7. Data sources — where to look each thing up](#7-data-sources--where-to-look-each-thing-up)
- [8. Scoring approach — bridge to the tool](#8-scoring-approach--bridge-to-the-tool)
- [9. Common anti-patterns](#9-common-anti-patterns)
- [10. Worked example — picking an alternative to North Europe](#10-worked-example--picking-an-alternative-to-north-europe)
- [11. References](#11-references)

---

## 1. When to use this framework

This framework is scoped to *"which Azure region should I put this in?"* It
applies whenever any of the following is true:

| Scenario | Trigger | Example |
|---|---|---|
| **Growth** | Existing hub is capacity-constrained; new workload / new pipeline needs to land somewhere | *"North Europe won't approve my quota — where do I go?"* |
| **DR / failover** | Your DR region has become as constrained as your primary | *"West Europe is my DR for North Europe and both are constrained"* |
| **Migration** | Sovereignty, cost, or latency has changed and the current region is no longer optimal | *"Post-Brexit we need UK data residency for a workload currently in NL"* |
| **Cost optimisation** | You've discovered your dev/test or batch runs 10-15% cheaper in a green region | *"Sweden Central for AI training"* |
| **New workload greenfield** | You're deciding where to start | *"Where do I put a brand-new global e-commerce product?"* |

The framework does **not** replace:
- Application architecture decisions (active/active vs active/passive — that's a
  workload-shape question, not a region question).
- Detailed cost engineering (this framework gives you the price *delta signal*;
  the FinOps Engine or similar gives you the £ figures).
- Compliance sign-off (this framework tells you which regions *are consistent
  with* your sovereignty tier; only your CISO/DPO can sign off on the
  regulatory position).

## 2. Microsoft's five pillars

Microsoft's own [Level Up 300 — Accelerate Multi-region through hub and growth
region model][l300] framework says a region-selection conversation should
always cover these five, in this order. This is the *floor* — every
enterprise should extend it (see [§3](#3-extended-enterprise-dimensions)).

| # | Pillar | Question it answers | Authoritative source |
|:-:|--------|---------------------|----------------------|
| 1 | **Regional compliance** | Is this region in a geography that satisfies my data residency / sovereignty requirements? | [Microsoft datacenter map][dcservices] |
| 2 | **Service availability** | Are all the resource providers (services) I actually use available in this region? | ARM `az provider list` + [Products by region page][productsbyregion] |
| 3 | **Availability Zone support** | Does this region have Availability Zones? Do all my services support them here? | [Azure Services that support Availability Zones][azservicelist] |
| 4 | **Capacity constraints** | Is this region open for new deployments, or is it constrained? | [aka.ms/AzureCapacity][azcapacity] *(Microsoft-internal; Microsoft field team can share status)* |
| 5 | **Latency** | What's the round-trip time from my users / hub / on-prem to this region? | [Azure network round-trip latency statistics][azlatency] |

The [`Get-AzureServicesByRegion.ps1`](../Get-AzureServicesByRegion.ps1) and
[`Compare-AzureRegionCoverage.ps1`](../Compare-AzureRegionCoverage.ps1) scripts
already answer pillars 2 and (partially) 3. [`Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1)
scores all five plus the extended dimensions below.

## 3. Extended enterprise dimensions

The five pillars are necessary but not sufficient. Every enterprise that
actually moves a workload discovers these additional dimensions matter:

| # | Dimension | Question it answers | Why the five pillars miss it |
|:-:|-----------|---------------------|-----------------------------|
| 6 | **Compute pricing delta** | Is compute meaningfully cheaper (or more expensive) here? Retail Prices API often shows 5-15% spread across EU regions. | Cost isn't in the five pillars but frequently drives the decision. |
| 7 | **Egress / cross-region peering cost** | If I keep my hub where it is and put new workloads here, what does the peering cost me? | Peering between paired regions is different from cross-region; this materially affects the business case. |
| 8 | **Zone-count-driven fit** | I need 3-zone deployment resilience. Does this region support 3 AZs *right now*, or is one AZ constrained? | AZ support is binary in the five pillars; real capacity conversations are AZ-by-AZ. |
| 9 | **SKU family portability** | The specific VM families I lean on (e.g. Dv5, Eav6) — are they available here at scale? | "Service is available" ≠ "the specific SKU I need is deployable at my scale." |
| 10 | **Paired-region vs 3+0 topology** | Does this region have a Microsoft-defined paired region for platform-managed replication (Storage GRS, Backup, Key Vault DR)? Or is it a `3+0` region where you own replication? | Microsoft is shipping new regions **without** paired regions (especially in EMEA), which fundamentally changes DR design. |
| 11 | **Sovereignty tier fit** | Does my organisation's sovereignty classification (UK-only / EU-OK / Global-OK) permit deployment here? | The five pillars talk about "regional compliance" abstractly; you need a tier system to make it operational. |
| 12 | **Regulated-workload scope** | Would putting this workload here expand my PCI-DSS / HIPAA / ISO audit scope? At what cost? | Compliance boundaries have their own real cost (audit fees, NVA duplication, HSM replication). |
| 13 | **Capacity-guarantee mechanisms available** | Can I use ODCR / Quota Groups / Ballast / Flexible VMSS to defend against allocation failure here? | Some mechanisms are region-specific (ODCR is per-region-per-SKU); some Preview features may not exist everywhere. |
| 14 | **Region maturity** | Is this a mainstream established region, or a brand-new one with the "Day 1 gaps" that comes with new regions? | New regions (Denmark East, Belgium Central) often have all the marketing but missing services or SKUs. |
| 15 | **Green / renewable-energy factor** | For AI/ML and other high-compute workloads, does this region source significant renewable energy? | Sustainability is a business-level filter that doesn't fit under any other pillar. |
| 16 | **ExpressRoute peering proximity** | Is there an ExpressRoute peering location close to this region, or will my private-link traffic tromboned through a distant hub? | Latency to the region ≠ latency for on-prem-to-region private traffic. |
| 17 | **Region pair asymmetry** | If I do have a paired region, is the pair symmetric (both regions equal-sized) or asymmetric (one is a satellite)? | Asymmetric pairs (UK South ↔ UK West) have very different resilience characteristics from symmetric pairs. |

## 4. Hard filters vs soft factors

**Hard filters** short-circuit ineligibility. If a region fails a hard filter,
it's out — no amount of latency, cost, or capacity advantage rescues it. Hard
filters are usually the compliance / policy layer.

**Soft factors** are trade-offs. You score each region on each factor, apply
weights that reflect your organisation's priorities, and rank by the weighted
sum. This is where most of the framework lives.

| Criterion | Typical disposition | Notes |
|-----------|:--:|-------|
| Regional compliance / geography | **Hard** | If your data must stay in the UK, non-UK regions are rejected. |
| Sovereignty tier fit | **Hard** | Same as above but expressed at organisation-classification level. |
| Regulated-workload scope | **Hard** for in-scope workloads | PCI workloads: reject regions that would expand audit scope. |
| Service availability | **Soft** with a hard floor | You *could* redesign to avoid a missing service, but if 30% of your inventory is missing you probably won't. |
| AZ support | **Hard** for zone-required workloads / **Soft** otherwise | If workload declares 3-zone requirement, non-AZ regions are rejected. |
| Capacity constraints | **Soft**, escalates to **Hard** | Regions with "all new subscriptions restricted" become hard rejections for greenfield; soft for known-existing workloads. |
| Latency | **Soft** | Weight higher for latency-sensitive workloads. |
| Compute pricing delta | **Soft** | |
| Egress cost | **Soft** | |
| SKU family portability | **Soft** with a hard floor | 100% portability = full score; <50% often triggers a re-architecture decision. |
| Paired-region topology | **Informational** | Surfaces as context for the DR design; not a rejection criterion. |
| Region maturity | **Soft** | Weight higher for critical-prod, lower for dev/test. |
| Renewable energy | **Soft** | Weight per organisational sustainability policy. |
| Capacity-guarantee mechanisms | **Informational** | Availability of ODCR/Flex VMSS is worth knowing but rarely a rejection. |

## 5. Mapping to the Well-Architected Framework

The [Azure Well-Architected Framework][waf] gives a familiar language for
enterprise decision-makers. Every criterion above maps to one or more of the
five WAF pillars:

| Criterion | Reliability | Security | Cost Optimization | Operational Excellence | Performance Efficiency |
|-----------|:--:|:--:|:--:|:--:|:--:|
| Regional compliance / sovereignty | · | ✓ | · | · | · |
| Service availability | ✓ | · | · | ✓ | · |
| AZ support | ✓ | · | · | · | ✓ |
| Capacity constraints | ✓ | · | · | ✓ | · |
| Latency | · | · | · | · | ✓ |
| Compute pricing delta | · | · | ✓ | · | · |
| Egress cost | · | · | ✓ | · | · |
| Zone-count-driven fit | ✓ | · | · | · | ✓ |
| SKU family portability | ✓ | · | ✓ | · | ✓ |
| Paired-region topology | ✓ | · | · | ✓ | · |
| Regulated-workload scope | · | ✓ | ✓ | · | · |
| Region maturity | ✓ | · | · | ✓ | · |
| Renewable energy | · | · | · | · | · |
| ExpressRoute proximity | · | · | · | · | ✓ |
| Capacity-guarantee mechanisms | ✓ | · | ✓ | ✓ | · |

Enhancing one pillar can create trade-offs against another (e.g. selecting a
region on pure cost may worsen latency). This is normal — the framework's
weighting model in [§8](#8-scoring-approach--bridge-to-the-tool) makes the
trade-off explicit.

## 6. Full criterion catalogue

Each criterion below follows the same shape:

```
### C-N — Criterion name
Question | What you're actually asking
Why      | Why it matters
Source   | Where to get the data (public link or API or "internal — ask MSFT")
Disposition | Hard filter, soft score, or informational
Notes    | Gotchas, common pitfalls
```

### C-1 — Regional compliance / geography

- **Question:** Is this region in a geography that satisfies my data
  residency / sovereignty requirements?
- **Why:** Data residency is often a legal requirement, not a preference.
  Storing customer PII in the wrong geography can be a regulatory
  breach with fines under GDPR, DPA 2018, etc.
- **Source:** `az account list-locations -o json` → `metadata.geographyGroup`,
  `metadata.physicalLocation`, `metadata.regionType`; [Microsoft datacenter
  map][dcservices].
- **Disposition:** Hard filter.
- **Notes:** Geography ≠ Country. "Europe" as a geography contains regions in
  Ireland, Netherlands, Germany, France, Switzerland, Norway, Sweden, UK,
  Italy, Spain, Poland, Austria, Belgium, Denmark. If your sovereignty tier is
  "UK-only," only UK South / UK West satisfy it; "EU-OK" opens up ~15 regions.

### C-2 — Service availability

- **Question:** Are all the Azure resource providers (services) I actually
  use available in this region?
- **Why:** A missing provider means either (a) that service can't be
  deployed to this region at all, or (b) you'd need to route to the service
  hosted in a different region (introducing latency + cross-region peering
  cost + operational complexity).
- **Source:** `az provider list` + your Resource Graph inventory (this
  repo's [`Compare-AzureRegionCoverage.ps1`](../Compare-AzureRegionCoverage.ps1)
  already does the cross-reference); [Products by region][productsbyregion]
  for the human-friendly view.
- **Disposition:** Soft score with a hard floor (typical enterprise cutoff:
  <70% coverage is a rejection).
- **Notes:** Provider-level availability is a first cut. Some resource
  *types within a provider* are more restricted than others; if you're
  choosing on a specific service you should check the resource-type list
  directly (`resourceTypes[].locations` in the `az provider show` JSON).

### C-3 — Availability Zone support

- **Question:** Does this region have 3 Availability Zones, and do the
  Azure services I use support AZs *here*?
- **Why:** AZ redundancy is Microsoft's headline in-region resilience
  pattern. Without AZs, a single datacenter fault takes the whole region
  offline. Some services (e.g. Basic-tier load balancers) don't support AZs
  even in regions that have them.
- **Source:** `az account list-locations` returns `availabilityZoneMappings`;
  [Azure Services that support Availability Zones][azservicelist] for the
  service-by-service list.
- **Disposition:** Hard filter for zone-required workloads; soft score
  otherwise.
- **Notes:** Some regions are documented as "AZ-supported" but with
  material zone-level capacity constraints (i.e. one AZ is out of stock).
  This is what C-8 (zone-count fit) drills into.

### C-4 — Capacity constraints (region-level)

- **Question:** Is this region currently open for new deployments, or is
  new-subscription onboarding / quota uplift restricted?
- **Why:** A region can be technically supported for a service and still
  be effectively closed to new customers if Microsoft has flagged it as
  capacity-constrained. Deploying into a constrained region will result in
  quota-request denials, allocation failures at deployment time, and slow
  or refused uplift decisions during peak.
- **Source:** [aka.ms/AzureCapacity][azcapacity] (Microsoft internal —
  ask your account team). The
  [`Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1) tool accepts an
  optional CSV override
  ([`data/capacity-status-template.csv`](../data/capacity-status-template.csv))
  in the Capacity Portal shape so this data can be layered in when you have
  access.
- **Disposition:** Hard filter for greenfield; soft score for existing
  workloads.
- **Notes:** "Constrained" is a spectrum. Microsoft's own portal uses:
  *only classic/specialty constraints* (green, effectively open), *short-term
  server gap* (yellow, mitigation in weeks), *long-term gap* (orange, months
  or years), *all new subscriptions restricted* (red, closed). See
  [§9](#9-common-anti-patterns) for common misreadings.

### C-5 — Latency (RTT to hub / users / on-prem)

- **Question:** What's the round-trip time from where my users, my hub,
  and my on-prem sit to this region?
- **Why:** Latency has three separate impacts:
  1. User-facing responsiveness (matters for transactional / interactive apps).
  2. Application-to-database latency (matters for tightly-coupled compute + data).
  3. Cross-region operational latency (matters for platform components:
     identity, monitoring, DNS).
- **Source:** [Azure network round-trip latency statistics][azlatency] — a
  point-in-time percentile RTT table for every region pair. Snapshot in
  this repo at [`data/latency-baseline.json`](../data/latency-baseline.json).
- **Disposition:** Soft score.
- **Notes:** Latency due to geographical distance is a physics constraint —
  no amount of Microsoft-side capacity fixes it. Latency due to congestion
  is provisioned away by Microsoft on the Azure WAN, but *not* on the
  internet. So user-to-Azure latency will vary; region-to-region latency
  is stable.

### C-6 — Compute pricing delta

- **Question:** Is compute in this region meaningfully cheaper (or more
  expensive) than my source region?
- **Why:** The Retail Prices API exposes hourly on-demand rates per SKU
  per region. EU regions show a 5–15% spread on the same VM family (Sweden
  Central is often cheapest for D-family Intel). Multiplied over an
  enterprise's compute base, that's real money.
- **Source:** [Azure Retail Prices API][retailprices] —
  `https://prices.azure.com/api/retail/prices`. The
  [`Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1) tool fetches a
  representative basket derived from your inventory and computes the delta.
- **Disposition:** Soft score.
- **Notes:** Applied Reserved Instance discounts and Savings Plans further
  reduce cost but are broadly consistent across regions in a geography.
  The retail rate is a good proxy for the delta. Also: cheaper compute is
  often offset by egress cost — see C-7.

### C-7 — Egress / cross-region peering cost

- **Question:** If I put a new workload here but keep my hub / user access /
  data in the existing region, what does the cross-region peering cost me?
- **Why:** Cross-region VNet peering costs meaningfully more than
  in-region: for EU regions, roughly $7/100GB cross-region vs $2/100GB
  in-region. High-egress workloads (media streaming, bulk data transfer)
  break this business case; low-egress workloads (typical microservices
  behind Front Door) don't.
- **Source:** [Azure Bandwidth Pricing page][bandwidthpricing] +
  [`data/egress-rates.json`](../data/egress-rates.json).
- **Disposition:** Soft score.
- **Notes:** Rule of thumb: at ~240GB/month cross-region egress, the
  extra peering cost matches the 10% compute saving on a 4-core VM in
  Sweden Central vs North Europe. Front Door / CDN traffic doesn't
  count — user traffic terminates at the AFD PoP, not at your origin.

### C-8 — Zone-count-driven fit

- **Question:** My workload requires N-zone resilience — does this region
  have N healthy AZs available *right now*?
- **Why:** A region can be advertised as AZ-supporting while one of its
  three AZs is capacity-constrained (all new subscriptions blocked in
  AZ02, for example). A 3-zone deployment in that region can't be
  provisioned even though the region is nominally "AZ-supported."
- **Source:** Microsoft Capacity Portal (internal); the
  [`Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1) tool accepts
  the same override CSV as C-4 which includes AZ-level rows.
- **Disposition:** Hard filter for workloads that declare a zone-count
  requirement; soft score otherwise.
- **Notes:** Microsoft's own June 2026 guidance for constrained UK South
  reflects this exact issue: single-zone (regional) deployments are
  becoming viable again while 2-zone and 3-zone deployments remain
  blocked until specific mitigation dates.

### C-9 — SKU family portability

- **Question:** The specific VM families my inventory relies on — are
  they broadly deployable in this region, or would I need to substitute
  SKUs?
- **Why:** The bulk of an enterprise's compute footprint concentrates in a
  small number of SKU families (Dv5, Ev5, Fs, Ea). Some families are
  broadly available (Intel Dv5 across most regions); some are narrower
  (specialty GPU / HBM / confidential compute SKUs); and some regions have
  family-specific capacity gaps (WE has flagged AMD family constraints).
- **Source:** Retail Prices API + Resource Graph inventory. Compute the
  family concentration in the source region, then check family availability
  in each candidate.
- **Disposition:** Soft score with a hard floor (if <50% of your inventory
  by count is portable, you have a re-architecture project on your hands).
- **Notes:** SKU generation matters — v2 SKUs are being sunsetted; v6/v7
  are the newest and often available in fewer regions initially.
  Modernising SKU generation is a separate track from region selection but
  affects both.

### C-10 — Paired-region vs 3+0 topology

- **Question:** Does this region have a Microsoft-defined paired region,
  or is it a `3+0` (no-paired) region?
- **Why:** Several Azure services (Storage GRS, Key Vault DR, Backup GRS)
  historically replicated to a Microsoft-selected paired region. Microsoft
  is now launching regions **without** a paired region (especially in
  EMEA); customers must design their own replication in these regions.
  This isn't better or worse — it's *different*, and it changes your DR
  architecture.
- **Source:** `az account list-locations -o json` → `metadata.pairedRegion`.
- **Disposition:** Informational (surfaces in the report as context).
- **Notes:** Belgium Central, Denmark East, Spain Central are `3+0`
  regions. If your DR strategy depends on Storage GRS or Backup GRS to a
  paired region, deploying to a `3+0` region requires you to switch to
  region-of-choice / customer-managed replication.

### C-11 — Sovereignty tier fit

- **Question:** Does my organisation's own sovereignty classification
  permit deployment here?
- **Why:** Most enterprises operate a 2- or 3-tier sovereignty
  classification (e.g. UK-only / EU-OK / Global-OK). Which tier a workload
  falls under determines the set of allowed regions — but the
  classification is *organisational*, not something the tool can infer.
- **Source:** Your organisation's data classification policy. Encoded into
  the tool via the `-DataResidency` CLI parameter.
- **Disposition:** Hard filter.
- **Notes:** This is often confused with C-1 (regional compliance).
  C-1 says which regions are legally in-scope for a given regulation;
  C-11 says which regions *your organisation permits*, which is usually
  a stricter set.

### C-12 — Regulated-workload scope

- **Question:** Would putting this workload here expand my PCI-DSS /
  HIPAA / ISO audit scope?
- **Why:** Bringing a new region into an audit scope adds cost (QSA time,
  NVA duplication, HSM replication) and risk (each region must maintain
  the compliance posture).
- **Source:** Your compliance / audit organisation.
- **Disposition:** Hard filter for in-scope workloads.
- **Notes:** The typical enterprise pattern is to keep regulated
  workloads pinned to a single geography (or a paired region) and use
  growth regions for *non-regulated* capacity overflow only. See
  [§9](#9-common-anti-patterns) for the anti-pattern of extending PCI
  scope to a growth region for a small cost saving.

### C-13 — Capacity-guarantee mechanisms available

- **Question:** Can I use ODCR (On-Demand Capacity Reservation) / Quota
  Groups / Capacity Ballast / Flexible VMSS to defend against allocation
  failures in this region?
- **Why:** These mechanisms are how you convert "quota granted" into
  "capacity physically reserved for me." If a region is constrained, ODCR
  fulfillment isn't guaranteed either (the physical hardware may not exist
  yet).
- **Source:** [Azure Capacity Reservations][odcrdocs],
  [Azure Quota Groups][quotagroupdocs], [Flexible VMSS orchestration mode][flexvmss].
- **Disposition:** Informational.
- **Notes:** Adopt in this order for a constrained hub: ODCR-within-existing-quota
  → Quota Groups (defragment across sibling subs) → Ballast pattern
  (non-prod as DR reserve) → Flexible VMSS (multi-SKU node pools).

### C-14 — Region maturity

- **Question:** Is this region a mainstream established region, or brand
  new?
- **Why:** New regions often have all the marketing (Denmark East, Belgium
  Central launched in 2025-2026) but missing individual services or SKUs.
  This is fine for greenfield dev/test / non-critical workloads and
  problematic for critical-prod.
- **Source:** `az account list-locations` metadata + Microsoft product
  announcements.
- **Disposition:** Soft score. Higher weight for critical-prod, lower for
  dev/test.
- **Notes:** As a rule of thumb, a new region typically reaches
  service-parity with mainstream regions in 12-18 months post-GA. Denmark
  East (GA 2026) is the current EMEA "day 1 region" case study.

### C-15 — Renewable energy / green

- **Question:** For AI/ML and other high-compute workloads, does this
  region source significant renewable energy?
- **Why:** For customers with public sustainability commitments, this
  can be a filter. Sweden Central is Microsoft's headline example of a
  primarily-hydroelectric region.
- **Source:** [Microsoft sustainability datacenters page][sustainability].
- **Disposition:** Soft score per organisational policy.
- **Notes:** Not a technical criterion — a business one. Weight it high
  only if there's a formal net-zero/scope-3 commitment.

### C-16 — ExpressRoute peering proximity

- **Question:** Is there an ExpressRoute peering location close to this
  region?
- **Why:** Private ExpressRoute traffic from on-prem to the region
  transits your ER circuit's peering location. If your ER peers in London
  and your target region is Sweden Central, on-prem-to-region private
  traffic still enters the Microsoft WAN in London.
- **Source:** [Azure ExpressRoute locations][erlocations].
- **Disposition:** Soft score for workloads with heavy private (non-Front-Door)
  on-prem-to-region traffic.
- **Notes:** For public / user-facing traffic terminated at Front Door /
  CDN, ER peering location doesn't matter — AFD handles global routing.

### C-17 — Region-pair asymmetry

- **Question:** If this region has a paired region, is the pair
  symmetric (both regions equal size) or asymmetric (one is a smaller
  "satellite")?
- **Why:** Asymmetric pairs like UK South ↔ UK West behave differently
  from symmetric pairs like North Europe ↔ West Europe. In an asymmetric
  pair, the satellite may lack AZs, have limited service availability,
  or be capacity-constrained even when the primary is healthy.
- **Source:** [Azure paired regions][pairedregions] + inspection of the
  paired region's own C-2 / C-3 / C-4 status.
- **Disposition:** Informational.
- **Notes:** If your DR strategy relies on the paired region and it's a
  satellite, you should evaluate it as a full region against all these
  criteria — don't assume equivalence.

## 7. Data sources — where to look each thing up

| Criterion | Public data source | API / CLI | Auto-scored in `Score-AzureRegionFit.ps1`? |
|-----------|-------------------|-----------|:--:|
| C-1 Compliance / geography | [Datacenter map][dcservices] | `az account list-locations` | Yes |
| C-2 Service availability | [Products by region][productsbyregion] | `az provider list` | Yes |
| C-3 AZ support | [AZ service list][azservicelist] | `az account list-locations` (`availabilityZoneMappings`) | Yes |
| C-4 Capacity (region) | [aka.ms/AzureCapacity][azcapacity] (internal) | Optional override CSV | Optional (via override) |
| C-5 Latency | [Azure latency stats][azlatency] | [`data/latency-baseline.json`](../data/latency-baseline.json) | Yes |
| C-6 Compute pricing | [Retail Prices API][retailprices] | `https://prices.azure.com/api/retail/prices` | Yes |
| C-7 Egress cost | [Bandwidth pricing][bandwidthpricing] | [`data/egress-rates.json`](../data/egress-rates.json) | Yes |
| C-8 Zone-count fit | [aka.ms/AzureCapacity][azcapacity] (internal) | Optional override CSV | Optional (via override) |
| C-9 SKU portability | Retail Prices API + inventory | Same as C-6 | Yes |
| C-10 Paired region | [Paired regions doc][pairedregions] | `az account list-locations` (`metadata.pairedRegion`) | Yes (informational surface) |
| C-11 Sovereignty tier | Your policy | `-DataResidency` param | Yes |
| C-12 Regulated scope | Your compliance team | `-RegulatedWorkload` param (planned) | No — manual |
| C-13 Capacity mechanisms | [Capacity Reservations][odcrdocs], [Quota Groups][quotagroupdocs], [Flexible VMSS][flexvmss] | Manual | No — informational |
| C-14 Region maturity | Microsoft product announcements | `az account list-locations` `metadata.regionCategory` | Yes (best-effort) |
| C-15 Renewable energy | [Sustainability page][sustainability] | Manual | No — manual |
| C-16 ExpressRoute proximity | [ER locations][erlocations] | Manual | No — manual |
| C-17 Region-pair asymmetry | [Paired regions][pairedregions] | Derived from `metadata.pairedRegion` size analysis | Yes (informational) |

## 8. Scoring approach — bridge to the tool

The [`Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1) tool converts
this catalogue into a per-region stack-rank as follows:

1. **Apply hard filters.** For each candidate region, evaluate the hard-filter
   criteria (C-1, C-11 always; C-3 / C-4 / C-8 / C-12 conditionally per CLI
   parameters). Any region that fails is rejected outright with a recorded
   rejection reason.
2. **Score soft factors.** For each remaining region, compute a `[0..1]`
   normalised score per soft criterion. Normalisation rules:
   - **Coverage** (C-2, C-9) — direct % coverage.
   - **Latency** (C-5) — lower is better; `1 - min(rtt / 100ms, 1.0)`.
   - **Price delta** (C-6) — cheaper than source is better;
     `0.5 + clamp(-priceDeltaPct / 20, -0.5, 0.5)`.
   - **Egress** (C-7) — lower rate is better; per-geography anchored.
   - **AZ support** (C-3, C-8) — binary or fractional per AZ count.
   - **Capacity health** (C-4) — 5-level ordinal converted to `[0..1]`.
3. **Apply weights.** Sum `weight_i × normalisedScore_i` for each region using
   the weights from [`data/scoring-weights.default.json`](../data/scoring-weights.default.json)
   (or a customer-supplied override).
4. **Rank and report.** Regions ordered by final score. The output includes
   the per-criterion breakdown so the ranking is defensible.

Sample output shape (see the actual samples in [`outputs/scorecard/`](../outputs/scorecard/)):

```
Rank  Region             Score  Coverage  Latency  Price   Egress  AZ   Capacity
  1   Sweden Central     0.87    0.98      0.62    0.75    0.50    1.0  1.0
  2   Belgium Central    0.82    0.95      0.85    0.55    0.50    1.0  1.0
  3   Poland Central     0.80    0.91      0.60    0.75    0.50    1.0  1.0
  ⛔  Norway East        —       —          —      —       —       —    REJECTED: capacity (all new restricted)
  ⛔  Germany North      —       —          —      —       —       —    REJECTED: sovereignty (UK-only, region in Germany)
```

## 9. Common anti-patterns

Real-world region-selection mistakes we've seen enough times to name:

- **"The paired region is my DR — I don't need to evaluate it."** Every
  paired region should pass the same C-1 through C-17 checks as your primary.
  A satellite region masquerading as a DR pair is a common failure mode.
- **"The five pillars are enough."** They're a floor, not a ceiling. Every
  enterprise workload eventually surfaces cost, sovereignty, or SKU-portability
  concerns that the five pillars don't cover.
- **"Products by region says the service is there, so we're fine."** Provider
  availability is a *necessary* condition, not a *sufficient* one. SKUs,
  quota, capacity, and specific feature GA status all vary within a "the
  service is available" region.
- **"Sweden Central is cheaper so let's put PCI there."** Extending your
  audit scope for a 10% compute saving is almost never worth it. Compliance
  cost per new region typically exceeds five-digit £ annually.
- **"We'll add capacity reservations to guarantee capacity."** ODCR is a
  reservation *against physical hardware in the region*. In a constrained
  region, Microsoft may not be able to fulfill the reservation. Validate
  with your account team before sizing the workstream.
- **"Norway East is unconstrained — let's grow there."** Historical
  status. A region that was healthy last quarter can be capacity-frozen
  this quarter (as Norway East did in mid-2026). Always check current
  status at [aka.ms/AzureCapacity][azcapacity] or via your Microsoft
  account team.
- **"We'll deploy the new workload to the source region and cross-region
  peer it back to itself."** The trombone effect: spoke-to-spoke traffic
  in a new region routes through the source-region hub. For workloads with
  chatty spoke-to-spoke patterns this adds material latency. Use AVNM
  Connected Groups if the traffic can bypass firewall inspection.
- **"Microsoft's paired region will replicate everything for me."**
  Increasingly false. New regions ship as `3+0` without paired-region
  service-managed replication. Design app-level / data-level replication
  now so you're ready when your target region is `3+0`.

## 10. Worked example — picking an alternative to North Europe

Scenario: a UK-headquartered enterprise runs 80% of its Azure footprint in
North Europe (Ireland). NE has been classified as "long-term gap, all new
subscriptions restricted" and quota uplifts are frozen. The enterprise
needs to shape *new* growth to an alternative EMEA region (existing
workloads stay in NE for now).

Applying the framework:

1. **Sovereignty tier** = "EU-OK" (workload is not UK-only or Global-OK).
   All EU regions in scope.
2. **Hard filters applied.** Norway East ("all new subs restricted, TBD
   mitigation") — **rejected**. North Europe and West Europe (source
   hubs) — **excluded** as they're the ones being escaped.
3. **AZ requirement** = 2-zone (typical modern e-commerce). Non-AZ
   regions filtered.
4. **Candidates:** Sweden Central, Belgium Central, Poland Central,
   Germany West Central, Italy North, Denmark East, Spain Central,
   Austria East, France Central, Switzerland North.
5. **Soft-score weights** for this scenario (from a workshop):
   - Coverage: 25% (must run our services)
   - Latency to NE hub: 20% (hub-and-spoke pattern)
   - Compute price delta: 15% (cost-positive move)
   - AZ support: 15% (2-zone required)
   - Capacity health: 15% (want a region that will still be open in 6 months)
   - Egress cost: 5%
   - Region maturity: 5%
6. **Rank output** (illustrative; run the tool for actual numbers):
   - Sweden Central (0.87) — Microsoft's own #1 alt, ~10% cheaper compute,
     3 AZs open, mature.
   - Belgium Central (0.82) — closest latency to NE (~15ms), 3 AZs (with
     AZ01 mild caveat), new region.
   - Italy North (0.80) — promoted by Microsoft's June 2026 guidance,
     ~30ms latency, mature.
   - Poland Central (0.78) — cheap, 3 AZs, ~35ms latency.
   - Denmark East (0.73) — brand-new, unconstrained, "day 1 region" caveat.
7. **Decision**: choose 1-2 primary regions rather than a single one.
   E.g. Sweden Central for cost-optimised / batch / AI workloads +
   Belgium Central for latency-sensitive user-facing overflow. Reserve
   Poland Central / Italy North / Denmark East as future options.

The specific weights, the specific rank, and the specific decision are the
customer's — the framework and tool ensure the process is repeatable,
grounded in current data, and defensible to leadership.

## 11. References

**Microsoft official guidance**

- [aka.ms/AzureCapacity][azcapacity] — current Azure region and zone
  constraints (Microsoft-internal; ask your account team).
- [Azure datacenter services][dcservices] — geography / region map.
- [Products by region][productsbyregion] — human-friendly service-by-region view.
- [Azure Services that support Availability Zones][azservicelist].
- [Azure network round-trip latency statistics][azlatency].
- [Azure Retail Prices API][retailprices].
- [Azure Bandwidth Pricing][bandwidthpricing].
- [Azure paired regions][pairedregions].
- [Azure ExpressRoute locations][erlocations].
- [Microsoft datacenter sustainability][sustainability].
- [Azure Capacity Reservations][odcrdocs].
- [Azure Quota Groups][quotagroupdocs].
- [Flexible VMSS orchestration mode][flexvmss].
- [Azure Well-Architected Framework][waf].
- [FY26 Multi-region Skilling Plan][fy26skilling] (internal — ask your
  Microsoft account team for level-up sessions).

**Sibling tools in this repo**

- [`Get-AzureServicesByRegion.ps1`](../Get-AzureServicesByRegion.ps1) —
  produces the service catalogue per region (feeds C-2 scoring).
- [`Compare-AzureRegionCoverage.ps1`](../Compare-AzureRegionCoverage.ps1) —
  scores every region on service coverage (feeds C-2 and C-9 scoring).
- [`Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1) — the full
  stack-rank tool driven by this framework.

[l300]: https://microsoft.sharepoint.com/teams/AzureReliabilityPortal/OpenToEveryone/Capacity/Capacity%20Guides/ "FY26 Level Up 300 — Multi-region"
[dcservices]: https://azure.microsoft.com/en-us/explore/global-infrastructure/
[productsbyregion]: https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/table
[azservicelist]: https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support
[azcapacity]: https://aka.ms/AzureCapacity
[azlatency]: https://learn.microsoft.com/en-us/azure/networking/azure-network-latency
[retailprices]: https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices
[bandwidthpricing]: https://azure.microsoft.com/en-us/pricing/details/bandwidth/
[pairedregions]: https://learn.microsoft.com/en-us/azure/reliability/regions-paired
[erlocations]: https://learn.microsoft.com/en-us/azure/expressroute/expressroute-locations-providers
[sustainability]: https://datacenters.microsoft.com/sustainability/
[odcrdocs]: https://learn.microsoft.com/en-us/azure/virtual-machines/capacity-reservation-overview
[quotagroupdocs]: https://learn.microsoft.com/en-us/azure/quotas/quota-groups
[flexvmss]: https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-orchestration-modes
[waf]: https://learn.microsoft.com/en-us/azure/well-architected/
[fy26skilling]: https://aka.ms/FY26multi-regionSkillingPlan
