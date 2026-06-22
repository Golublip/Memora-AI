skills:
  - name: load_dataset
    description: Reads the CSV dataset, validates columns, and lists/flags the null actual_spend rows.
    input: File path (string).
    output: List of dictionaries representing the CSV data.
    error_handling: Raises FileNotFoundError if the file is missing; logs warnings for missing columns or unexpected data formats.

  - name: compute_growth
    description: Computes MoM or YoY growth for a specific ward and category, incorporating null-checking, formula logging, and refusal checks.
    input: Data list, ward (string), category (string), growth_type (string).
    output: List of calculated rows showing period, actual spend, growth rate, formula, and status.
    error_handling: Refuses calculation (exits with error) if ward or category is "all"/"any" or if growth_type is missing.
