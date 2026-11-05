"""Demo: append each term's enrollment to the teaching-evaluation cells of a CV Rmd."""
import re
import sys

# enrollment by (course, term); from the evaluation reports and the 115-1 course list
ENROLLMENT = {
    "stat": {"2024-fall": 44, "2025-spring": 46, "2025-fall": 51, "2026-spring": 49, "2026-fall": 54},
    "da": {"2024-fall": 58, "2025-fall": 48, "2026-fall": 54},
    "pa": {"2024-spring": 30, "2025-spring": 37, "2026-spring": 42},
}
PENDING = {"en": r"\textit{pending}", "zh": "待公布"}
NOTE = {"en": r"\textit{Note}: Number of enrolled students in parentheses.",
        "zh": "附註：括號內為修課人數。"}
SCORE = re.compile(r"(\\href\{https://yyliou\.github\.io/yyliou/cv/cert/teaching/(\w+)-(\d{4}-\w+)\.pdf\}\{[\d.]+\})")


def with_enrollment(row, lang):
    course = re.search(r"yyliou\.github\.io/(stat|da|pa)\}", row).group(1)
    row = SCORE.sub(lambda m: f"{m.group(1)} ({ENROLLMENT[m.group(2)][m.group(3)]})", row)
    pending = PENDING[lang]
    if pending not in row:
        return row
    return row.replace(pending, f"{pending} ({ENROLLMENT[course]['2026-fall']})")


def revise(text, lang):
    lines = text.split("\n")
    for i, line in enumerate(lines):
        if re.match(r"\\href\{https://yyliou\.github\.io/(stat|da|pa)\}", line):
            lines[i] = with_enrollment(line, lang)
    text = "\n".join(lines)
    end = r"\end{tabular*}}\par\vspace{3pt}"
    assert text.count(end) == 1
    return text.replace(end, end + "\n{\\footnotesize " + NOTE[lang] + "\\par}\\vspace{3pt}")


if __name__ == "__main__":
    source, target, lang = sys.argv[1:]
    open(target, "w", encoding="utf-8").write(revise(open(source, encoding="utf-8").read(), lang))
