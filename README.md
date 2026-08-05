# RizScript 

RizScript is a custom domain-specific programming language built using **Flex (Lex)**, **Bison (Yacc)**, and **C**. It features a clean syntax designed for simple mathematical, logical, and execution flow operations.

---

##  Features

RizScript satisfies all core requirements for the custom domain-specific language implementation:

- **Custom Identity:** 
  - **Language Name:** RizScript
  - **Custom File Extension:** `.rz`

- **Variables:**
  - Dynamic variable declaration and runtime assignment using the `let` keyword.

- **Operators:**
  - **Arithmetic:** Standard operations including addition (`+`), subtraction (`-`), multiplication (`*`), and division (`/`).
  - **Logical & Comparison:** Conditional comparisons using `>`, `<`, `==`, and `!=`.

- **Control Flow:**
  - **Conditional Statements:** `check` and `otherwise` blocks (equivalent to `if`/`else`).
  - **Loops:** Iterative execution support via `while` / `for` loop constructs.

- **I/O (Input/Output):**
  - **Output:** Built-in `echo()` statement for rendering text and variable evaluations to the terminal.
  - **Runtime Input:** Interactive input collection using `ask()`.

---

##  Project Structure
```text
RizScript/
├── examples/             # Sample RizScript program files (.rz)
│   ├── discount.rz
│   ├── even_odd.rz
│   └── simple_calc.rz
├── src/                  # Source files for Lexer and Parser
│   ├── lexer.l
│   └── parser.y
├── Makefile              # Build automation script
├── Language_Manual.txt   # Documentation & syntax guidelines
└── README.md             # Project documentation
```
## Challenges Faced
1. **Syntax Errors in Bison:** Fixing shift/reduce conflicts while implementing check and otherwise statements.
2. **User Input Handling:** Correctly taking runtime input with ask() and saving it in dynamic variables.
3. **Token Conflicts:** Avoid conflicts between custom keywords (like echo, let, ask) and normal variable names in Flex.

## Building & Running
```text
  make
./rizscript examples/simple_calc.rz
(You can run other scripts similarly: discount.rz, even_odd.rz)
```