skills:
  - name: retrieve_policy
    description: Loads a policy text file and parses it into structured sections and numbered clauses.
    input: File path (string).
    output: Structured representation of clauses (e.g. dictionary or list of strings).
    error_handling: Raises FileNotFoundError if the file is missing; logs a warning for empty files.

  - name: summarize_policy
    description: Generates a complete and compliant summary of the parsed policy clauses, preserving all binding verbs and multi-condition rules.
    input: Structured representation of clauses (e.g. dictionary or list of strings).
    output: Summarized policy content (string).
    error_handling: If any core clauses are missing or fail validation, falls back to quoting the original clauses verbatim in the summary.
