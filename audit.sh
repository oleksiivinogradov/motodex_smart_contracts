#!/bin/bash
# MotoDEX Security Audit Report Generator
# Runs Slither analysis and generates SECURITY_AUDIT_REPORT.md
#
# Usage: ./audit.sh
# Requirements: slither, python3, npx/hardhat

set -e

HARDHAT_DIR="/Users/alex/Documents/GitHub/motoDEX_contracts/motoDEX_contracts_hardhat_next"
OUTPUT_DIR="/Users/alex/Documents/GitHub/motodex_smart_contracts"
SLITHER_JSON="/tmp/slither-results.json"

echo "=== MotoDEX Security Audit ==="
echo ""

# 1. Run Slither
echo "[1/4] Running Slither analysis..."
cd "$HARDHAT_DIR"
slither . --json "$SLITHER_JSON" 2>/dev/null || true
echo "  ✔ Slither complete"

# 2. Copy contracts
echo "[2/4] Copying contracts..."
mkdir -p "$OUTPUT_DIR/contracts"
cp contracts/MotoDEX.sol "$OUTPUT_DIR/contracts/"
cp contracts/MotoDEXnft.sol "$OUTPUT_DIR/contracts/"
cp contracts/USDTmoto.sol "$OUTPUT_DIR/contracts/"
cp contracts/IMotoDEXnft.sol "$OUTPUT_DIR/contracts/"
cp contracts/IABSNFT.sol "$OUTPUT_DIR/contracts/"
cp "$SLITHER_JSON" "$OUTPUT_DIR/slither-results.json"
echo "  ✔ Contracts copied"

# 3. Generate report
echo "[3/4] Generating report..."

python3 << 'PYEOF'
import json
from datetime import datetime

with open("/tmp/slither-results.json") as f:
    data = json.load(f)

detectors = data.get("results", {}).get("detectors", [])

# Count by severity
counts = {}
for d in detectors:
    s = d["impact"]
    counts[s] = counts.get(s, 0) + 1

# Exclude OZ false positive from High count
high_findings = [d for d in detectors if d["impact"] == "High"]
oz_false_positives = [d for d in high_findings if "Math.mulDiv" in d.get("description", "")]
high_real = len(high_findings) - len(oz_false_positives)

report = []
report.append("# MotoDEX Smart Contracts — Slither Security Analysis Report\n")
report.append(f"**Date:** {datetime.now().strftime('%B %d, %Y')}  ")
report.append("**Tool:** Slither  ")
report.append("**Contracts Analyzed:** MotoDEX.sol, MotoDEXnft.sol, USDTmoto.sol, IMotoDEXnft.sol, IABSNFT.sol  ")
report.append("**Compiler:** Solidity 0.8.24\n")
report.append("---\n")
report.append("## Findings Summary\n")
report.append("| Severity | Count |")
report.append("|---|---|")
report.append(f"| High | {high_real} |")
report.append(f"| Medium | {counts.get('Medium', 0)} |")
report.append(f"| Low | {counts.get('Low', 0)} |")
report.append(f"| Informational | {counts.get('Informational', 0)} |")
report.append(f"| Optimization | {counts.get('Optimization', 0)} |")
total = sum(counts.values()) - len(oz_false_positives)
report.append(f"| **Total** | **{total}** |\n")

if oz_false_positives:
    report.append(f"> {len(oz_false_positives)} High-severity finding(s) in OpenZeppelin `Math.mulDiv` (`incorrect-exp`) excluded as known false positive.\n")

report.append("---\n")

# Print findings by severity
for severity in ["High", "Medium", "Low", "Informational", "Optimization"]:
    findings = [d for d in detectors if d["impact"] == severity]
    if not findings:
        continue

    report.append(f"## {severity} Severity Findings ({len(findings)})\n")

    if severity in ["High", "Medium"]:
        # Full output for High/Medium
        for i, d in enumerate(findings, 1):
            check = d["check"]
            desc = d["description"].strip()
            confidence = d.get("confidence", "N/A")
            report.append(f"### {severity[0]}-{i}: {check} (Confidence: {confidence})\n")
            report.append("```")
            report.append(desc)
            report.append("```\n")
    else:
        # Summary table for Low/Info/Optimization
        check_counts = {}
        for d in findings:
            c = d["check"]
            check_counts[c] = check_counts.get(c, 0) + 1

        report.append("| Check | Count |")
        report.append("|---|---|")
        for c, n in sorted(check_counts.items(), key=lambda x: -x[1]):
            report.append(f"| `{c}` | {n} |")
        report.append("")

    report.append("---\n")

output = "\n".join(report)

with open("/Users/alex/Documents/GitHub/motodex_smart_contracts/SECURITY_AUDIT_REPORT.md", "w") as f:
    f.write(output)

print(f"  Report generated: {len(detectors)} findings total")
print(f"  High: {high_real}, Medium: {counts.get('Medium',0)}, Low: {counts.get('Low',0)}, Info: {counts.get('Informational',0)}, Opt: {counts.get('Optimization',0)}")
PYEOF

echo "  ✔ Report generated"

# 4. Done
echo "[4/4] Done!"
echo ""
echo "Output:"
echo "  Report:    $OUTPUT_DIR/SECURITY_AUDIT_REPORT.md"
echo "  Contracts: $OUTPUT_DIR/contracts/"
echo "  Raw JSON:  $OUTPUT_DIR/slither-results.json"
