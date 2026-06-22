"""
UC-0C app.py — Budget Growth Calculator.
Build this using the RICE + agents.md + skills.md + CRAFT workflow.
See README.md for run command and expected behaviour.
"""
import argparse
import csv
import os
import re
import sys

def parse_period(p_str: str):
    parts = p_str.split("-")
    return int(parts[0]), int(parts[1])

def get_previous_period(period_str: str, growth_type: str) -> str:
    year, month = parse_period(period_str)
    if growth_type == "MoM":
        month -= 1
        if month == 0:
            month = 12
            year -= 1
    elif growth_type == "YoY":
        year -= 1
    return f"{year:04d}-{month:02d}"

def load_dataset(input_path: str) -> list:
    """
    Read CSV, validate columns, report null count.
    """
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Input file '{input_path}' not found.")
        
    rows = []
    null_count = 0
    null_rows_info = []

    with open(input_path, mode="r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        # Strip header spaces
        reader.fieldnames = [name.strip() for name in reader.fieldnames] if reader.fieldnames else []
        
        required_cols = {"period", "ward", "category", "budgeted_amount", "actual_spend", "notes"}
        if not required_cols.issubset(set(reader.fieldnames)):
            raise ValueError(f"Missing required columns in CSV. Found: {reader.fieldnames}")

        for line_num, row in enumerate(reader, start=2):
            # Strip values
            cleaned_row = {k: (v.strip() if v else "") for k, v in row.items()}
            actual_spend = cleaned_row.get("actual_spend", "")
            
            if actual_spend == "":
                null_count += 1
                null_rows_info.append(
                    f"Line {line_num}: Period={cleaned_row['period']}, Ward={cleaned_row['ward']}, "
                    f"Category={cleaned_row['category']}, Reason={cleaned_row['notes']}"
                )
            rows.append(cleaned_row)

    print(f"Dataset loaded. Total rows: {len(rows)}.")
    print(f"Total null actual_spend rows detected: {null_count}")
    for info in null_rows_info:
        print(f"  - {info}")

    return rows


def compute_growth(rows: list, ward: str, category: str, growth_type: str) -> list:
    """
    Compute MoM or YoY growth for a specific ward and category.
    """
    # 1. Enforce refusal rule: Never aggregate across wards or categories unless explicitly instructed
    refusal_keywords = {"all", "any", "total", ""}
    if not ward or ward.lower() in refusal_keywords:
        print("Error: Request refused. Calculation across multiple/all wards is not allowed.")
        sys.exit(1)
        
    if not category or category.lower() in refusal_keywords:
        print("Error: Request refused. Calculation across multiple/all categories is not allowed.")
        sys.exit(1)

    if not growth_type or growth_type not in {"MoM", "YoY"}:
        print("Error: Request refused. Growth type must be explicitly specified as MoM or YoY.")
        sys.exit(1)

    # Filter rows matching ward and category
    filtered = [
        row for row in rows
        if row["ward"].strip().lower() == ward.strip().lower()
        and row["category"].strip().lower() == category.strip().lower()
    ]

    if not filtered:
        print(f"Warning: No rows found for Ward='{ward}' and Category='{category}'.")
        return []

    # Sort chronologically by period
    filtered_sorted = sorted(filtered, key=lambda x: x["period"])
    
    # Create lookup map for easy historical retrieval
    lookup = {row["period"]: row for row in filtered_sorted}

    results = []

    for row in filtered_sorted:
        period = row["period"]
        actual_spend_str = row["actual_spend"]
        
        # Check if current month spend is null
        if actual_spend_str == "":
            growth = "NULL"
            note = row.get("notes", "No reason provided")
            formula = f"Flagged: {note}"
            results.append({
                "period": period,
                "ward": row["ward"],
                "category": row["category"],
                "actual_spend": "NULL",
                "growth": growth,
                "formula": formula
            })
            continue

        actual_spend = float(actual_spend_str)
        prev_period = get_previous_period(period, growth_type)

        if prev_period not in lookup:
            growth = "NULL"
            formula = f"n/a (no historical data for {prev_period})"
            results.append({
                "period": period,
                "ward": row["ward"],
                "category": row["category"],
                "actual_spend": f"{actual_spend:.1f}",
                "growth": growth,
                "formula": formula
            })
        else:
            prev_row = lookup[prev_period]
            prev_spend_str = prev_row["actual_spend"]
            
            if prev_spend_str == "":
                growth = "NULL"
                formula = f"Cannot compute (previous period {prev_period} is null)"
                results.append({
                    "period": period,
                    "ward": row["ward"],
                    "category": row["category"],
                    "actual_spend": f"{actual_spend:.1f}",
                    "growth": growth,
                    "formula": formula
                })
            else:
                prev_spend = float(prev_spend_str)
                diff = actual_spend - prev_spend
                growth_pct = (diff / prev_spend) * 100
                
                # Format growth string (e.g. +33.1%, -34.8%, 0.0%)
                if growth_pct > 0:
                    growth_str = f"+{growth_pct:.1f}%"
                elif growth_pct < 0:
                    # Note: Using standard minus hyphen
                    growth_str = f"{growth_pct:.1f}%"
                else:
                    growth_str = "0.0%"
                
                formula_str = f"({actual_spend:.1f} - {prev_spend:.1f}) / {prev_spend:.1f}"
                results.append({
                    "period": period,
                    "ward": row["ward"],
                    "category": row["category"],
                    "actual_spend": f"{actual_spend:.1f}",
                    "growth": growth_str,
                    "formula": formula_str
                })

    return results


def main():
    parser = argparse.ArgumentParser(description="UC-0C Budget Growth Calculator")
    parser.add_argument("--input", required=True, help="Path to ward_budget.csv")
    parser.add_argument("--ward", required=False, help="Specific ward name")
    parser.add_argument("--category", required=False, help="Specific category name")
    parser.add_argument("--growth-type", required=False, help="Growth type (MoM or YoY)")
    parser.add_argument("--output", required=True, help="Path to write growth_output.csv")
    args = parser.parse_args()

    # Enforce rule: if growth-type not specified, refuse and ask
    if not args.growth_type:
        print("Error: Refusing request. The --growth-type argument (MoM or YoY) is missing. Please specify it.")
        sys.exit(1)

    if not args.ward or args.ward.strip() == "":
        print("Error: Refusing request. The --ward argument is missing or empty.")
        sys.exit(1)

    if not args.category or args.category.strip() == "":
        print("Error: Refusing request. The --category argument is missing or empty.")
        sys.exit(1)

    try:
        rows = load_dataset(args.input)
        results = compute_growth(rows, args.ward, args.category, args.growth_type)
        
        # Write output CSV
        output_dir = os.path.dirname(os.path.abspath(args.output))
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)
            
        with open(args.output, mode="w", newline="", encoding="utf-8") as f:
            fieldnames = ["period", "ward", "category", "actual_spend", "growth", "formula"]
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for res in results:
                writer.writerow(res)
                
        print(f"Growth calculation completed. Output written to {args.output}")
    except Exception as e:
        print(f"Error during calculation: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
