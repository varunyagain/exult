# BPMN-style Process Flows (Markdown)

This document describes **two separate BPMN-style process flows** for a book-lending business model:

1. **Business-owned books** (business owns + lists inventory)
2. **Peer-owned books** (peers own + list inventory)

> Note: These are BPMN-*style* diagrams rendered in Markdown using Mermaid. They include BPMN concepts like **events, gateways, timers, lanes/roles, and message flows**.

---

## 1) Business-Owned Books — Borrow + Return + Deposits

### Actors / Lanes

* **Subscriber**
* **Business Platform** (app + wallet + rules engine)
* **Operations** (pickup/drop slots)

---

### BPMN-style flow (Mermaid)

```mermaid
flowchart TD

%% Mermaid in Obsidian is stricter than Mermaid Live.
%% This version avoids multi-line labels and special characters.

subgraph Subscriber
  S0((Start))
  S1[Browse catalogue]
  S2[Select book]
  S3[Submit borrow request]
  S4[Receive book at slot]
  S5[Use book]
  S6[Request extension]
  S7[Return book at slot]
  S8[Withdraw wallet balance]
  S9((End))
end

subgraph Platform
  P1[Validate active subscription]
  P2{Within borrow limit}
  P3[Get deposit for book]
  P4{Wallet sufficient}
  P5[Hold deposit in wallet]
  P6[Confirm borrow and schedule slot]
  P7[Start loan timer]
  P8{Extension requested}
  P9{Book reserved by others}
  P10[Approve extension 7 days]
  P11[Reject extension]
  P12((Timer 14 days))
  P13[Recall notice]
  P14{Returned by next slot}
  P15[Forfeit deposit]
  P16[Inspect condition]
  P17{Damaged}
  P18[Business decides damages]
  P19[Recover damages from deposit]
  P20[Credit deposit back to wallet]
  P22{Exceeded 21 days}
end

subgraph Operations
  O1[Run pickup or drop slot]
  O2[Deliver book]
  O3[Collect return]
end

S0 --> S1 --> S2 --> S3 --> P1 --> P2

P2 -- No --> P6
P2 -- Yes --> P3 --> P4

P4 -- No --> P6
P4 -- Yes --> P5 --> P6

P6 --> O1 --> O2 --> S4 --> S5 --> P7

%% Extension loop
S6 --> P8
P8 -- Yes --> P9
P9 -- No --> P10 --> P7
P9 -- Yes --> P11 --> P7

%% Recall path
P7 --> P12 --> P13 --> P14
P14 -- No --> P15 --> S9
P14 -- Yes --> P16

%% Return path
S5 --> S7 --> O1 --> O3 --> P16 --> P17
P17 -- Yes --> P18 --> P19 --> S9
P17 -- No --> P20 --> S8 --> S9

%% 21-day enforcement
P7 --> P22
P22 -- Yes --> P15
P22 -- No --> P8
```

---

### Key Rules Captured

* Borrowing requires:

  * Active subscription
  * Within simultaneous borrow limit
  * Per-book deposit available and held
* Loan duration:

  * **Max 21 days** → deposit forfeited if exceeded
  * Optional **7-day extensions**, repeatedly, but only if book not reserved/wishlisted
* Recall:

  * Business may recall **after 14 days**
  * If not returned by next slot → deposit forfeited
* Condition disputes:

  * Business decision is final
  * Deposit used to recover damages
* Wallet:

  * Deposit credited back if returned in good condition
  * Subscriber may withdraw wallet balance any time or on account closure

---

## 2) Peer-Owned Books — Request + Approval + Deposit + Dispute + Points

### Actors / Lanes

* **Borrower (Subscriber)**
* **Lender (Peer Owner)**
* **Business Platform** (escrow deposit + messaging + arbitration)
* **Operations** (pickup/drop slots)

---

### BPMN-style flow (Mermaid)

```mermaid
flowchart TD

%% Obsidian-friendly Mermaid (no multi-line labels)

subgraph Borrower
  B0((Start))
  B1[Browse peer books]
  B2[Select book]
  B3[Raise borrow request]
  B4[Receive approve or deny]
  B5[Receive book at slot]
  B6[Use book]
  B7[Return book at slot]
  B8((End))
end

subgraph Lender
  L1[List book]
  L2[Receive request]
  L3{Approve request}
  L4[Approve]
  L5[Deny]
  L6[Receive returned book]
  L7{Dispute condition}
  L8[Negotiate split in messages]
  L9[Agree split]
  L10[No agreement]
end

subgraph Platform
  P1[Validate borrower subscription]
  P2[Hold deposit in escrow]
  P3[Schedule earliest slot]
  P4[Open lending period]
  P5[Count points 10 per day]
  P6[Stop points counter]
  P7[Enable messaging]
  P8((Timer day 5))
  P9[Split deposit 50 50]
  P10[Execute deposit split]
  P11[Credit points to lender]
  P12[Points only for subscription]
end

subgraph Operations
  O1[Run pickup or drop slot]
  O2[Pickup from lender]
  O3[Deliver to borrower]
  O4[Pickup return from borrower]
  O5[Deliver return to lender]
end

L1 --> L2
B0 --> B1 --> B2 --> B3 --> P1 --> P2 --> L2

L2 --> L3
L3 -- No --> L5 --> B4 --> B8
L3 -- Yes --> L4 --> P3 --> O1

O1 --> O2 --> O3 --> B5 --> B6 --> P4 --> P5

B6 --> B7 --> O1 --> O4 --> O5 --> L6 --> P6
P6 --> P11 --> P12

L6 --> L7
L7 -- No --> P10 --> B8
L7 -- Yes --> P7 --> L8

L8 --> L9 --> P10 --> B8
L8 --> L10 --> P8 --> P9 --> B8
```

---

### Key Rules Captured

* Anyone may list books.
* Borrowing requires:

  * Borrower raises request
  * Lender approves
  * Business holds deposit in escrow for lender
* Scheduling:

  * Executed on **earliest delivery/pick-up slots**
* Disputes:

  * Business enables lender/borrower messaging
  * They must agree on deposit split
  * If no agreement by **day 5**, business splits deposit **50/50** (final)
* Points:

  * Lender earns **10 points/day** while lent
  * **Transit time excluded**
  * Points = **₹1 each**, usable only to pay subscription fees
  * Points can **never** be withdrawn

---

## Optional Add-on: Shared Weekly Slot Scheduling (Reusable Subprocess)

If you want, I can also add a reusable subprocess diagram for:

* Slot calendar generation (2+ weekly slots)
* Matching “earliest slot” for pickup and return
* Handling missed slots

---

## Next Upgrade (If You Want)

If you want these to be *even more BPMN-like*, I can produce a version with:

* Explicit **message flows**
* Separate **pools** (Subscriber vs Business vs Peer)
* Explicit **intermediate timer events** (21-day, 14-day recall, day-5 dispute)
* A compact layout suitable for investor pitch decks
