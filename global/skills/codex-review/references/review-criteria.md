# Software Engineering Review Criteria

Review the plan as a senior software engineer. Focus on whether the planned implementation will work correctly and follow good engineering practices. Security concerns are out of scope for this review.

## 1. Requirements Correctness

Evaluate whether the planned changes will actually achieve the stated goals.

- Do the described edits and additions correctly implement what the plan says it will achieve?
- Is the scope appropriate — neither too broad nor too narrow for the stated requirements?
- Are edge cases and boundary conditions addressed (empty inputs, concurrent access, failure paths)?
- Will the described commands and steps actually produce the expected results?
- Are there requirements mentioned in the Purpose section that are not addressed in the implementation steps?

## 2. DRY Principle and Code Quality

Evaluate whether the planned implementation avoids unnecessary duplication and follows sound design.

- Does the plan introduce duplicate code or logic that already exists elsewhere in the codebase?
- Are existing utilities, helpers, or functions being reused where appropriate?
- Are responsibilities clearly separated between functions and modules?
- Is there unnecessary abstraction or over-engineering for what could be a simpler solution?
- If similar patterns exist in the codebase, does the plan follow them consistently?

## 3. Simplicity and Readability

Evaluate whether the planned implementation is as simple as possible while meeting requirements.

- Does the plan achieve the requirements with minimal complexity?
- Are proposed variable names, function names, and module names clear and intention-revealing?
- Is the control flow intuitive and easy to follow?
- Will the resulting code be easy to maintain and modify in the future?
- Are there simpler alternatives to achieve the same result?

## 4. Technical Accuracy

Use your codebase access to verify the plan's references against reality.

- Do the file paths mentioned in the plan actually exist in the codebase? (Mark files explicitly described as "to be created" as acceptable.)
- Are function names, class names, and API references accurate?
- Are the dependencies (libraries, modules) actually available in the project?
- Are the commands described syntactically correct for the project's toolchain?
- Do the expected outputs described in validation steps match what would actually happen?

## 5. Severity Definitions

- **CRITICAL**: The plan, if implemented as written, will not meet the stated requirements or will break existing functionality.
- **MAJOR**: The implementation will work but has significant quality issues — DRY violations, excessive complexity, difficult maintenance, or misleading names.
- **MINOR**: The implementation is functional and quality is acceptable, but there are opportunities to improve naming, structure, or clarity.

## Out of Scope

Do NOT review for: input validation, authentication/authorization, injection attacks, or other security concerns. Focus exclusively on functional correctness, code quality, and readability.
