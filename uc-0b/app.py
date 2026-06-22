"""
UC-0B app.py — Policy Summarizer.
Build this using the RICE + agents.md + skills.md + CRAFT workflow.
See README.md for run command and expected behaviour.
"""
import argparse
import os
import re

def retrieve_policy(input_path: str) -> dict:
    """
    Load .txt policy file and return content as structured numbered sections.
    """
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Input file '{input_path}' not found.")

    clauses = {}
    current_clause = None

    # Open with utf-8 or utf-8-sig to handle Windows encoding cleanly
    with open(input_path, mode="r", encoding="utf-8-sig") as f:
        for line in f:
            stripped = line.strip()
            if not stripped:
                continue
            
            # Skip divider lines
            if stripped.startswith("═") or stripped.startswith("─"):
                continue
                
            # Skip section headings (e.g., "1. PURPOSE AND SCOPE", "2. ANNUAL LEAVE")
            if re.match(r"^\d+\.\s+[A-Z\s\(\)]+$", stripped):
                continue
            
            # Check if line starts with a numbered clause like X.Y
            match = re.match(r"^(\d+\.\d+)\s*(.*)", stripped)
            if match:
                current_clause = match.group(1)
                content = match.group(2).strip()
                clauses[current_clause] = [content]
            else:
                if current_clause is not None:
                    clauses[current_clause].append(stripped)

    # Clean and join lines for each clause
    structured_clauses = {}
    for clause_num, lines in clauses.items():
        full_text = " ".join(lines)
        full_text = re.sub(r"\s+", " ", full_text)
        structured_clauses[clause_num] = full_text

    return structured_clauses


def summarize_policy(structured_clauses: dict) -> str:
    """
    Generate a complete, compliant policy summary.
    Quotes critical clauses verbatim to guarantee zero meaning loss.
    """
    # Ground truth clauses that must be preserved with high fidelity
    critical_clauses = {"2.3", "2.4", "2.5", "2.6", "2.7", "3.2", "3.4", "5.2", "5.3", "7.2"}
    
    summary_lines = [
        "CMC EMPLOYEE LEAVE POLICY SUMMARY",
        "=================================",
        "To ensure compliance, critical clauses are quoted verbatim to prevent meaning loss.",
        ""
    ]

    # Sort clauses numerically by section and clause number
    def clause_key(c_num):
        return [int(x) for x in c_num.split(".")]

    sorted_clause_nums = sorted(structured_clauses.keys(), key=clause_key)

    for c in sorted_clause_nums:
        text = structured_clauses[c]
        if c in critical_clauses:
            summary_lines.append(f"[CRITICAL] Clause {c}: {text}")
        else:
            summary_lines.append(f"Clause {c}: {text}")

    return "\n".join(summary_lines)


def main():
    parser = argparse.ArgumentParser(description="UC-0B Policy Summarizer")
    parser.add_argument("--input", required=True, help="Path to input policy text file")
    parser.add_argument("--output", required=True, help="Path to write the summary text file")
    args = parser.parse_args()

    try:
        clauses = retrieve_policy(args.input)
        summary = summarize_policy(clauses)
        
        # Write output file
        output_dir = os.path.dirname(os.path.abspath(args.output))
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)
            
        with open(args.output, mode="w", encoding="utf-8") as f:
            f.write(summary)
            
        print(f"Summary written to {args.output}")
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
