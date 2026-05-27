#!/usr/bin/env python3
import subprocess
import sys
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

HTML2TEXT_ARGS = [
    "--body-width", "0",
    "--ignore-emphasis",
    "--ignore-links",
    "--ignore-images",
    "--ignore-tables",
    "--single-line-break",
    "--ignore-mailto-links",
]


# def get_available_dicts():
#     result = subprocess.run(["sdcv", "-l"], capture_output=True, text=True)
#     dicts = []
#     for line in result.stdout.strip().splitlines():
#         # print(line)
#         line = line.strip()
#         if not line or line.startswith("Dictionary's name") or line.startswith("dictd_www.dict.org_gcide") or line.startswith("Free On-Line Dictionary of Computing"):
#             continue
#         name = line.rsplit(None, 1)[0].strip()
#         dicts.append(name)
#     return dicts
def get_available_dicts():
    dicts = [
                 "quick_english-spanish",
                 "WordNet"
                 # "English - Spanish"
                 # "Free On-Line Dictionary of Computing",
                 # "Oxford Advanced Learner's Dictionary"
             ]
    return dicts



def get_selection():
    result = subprocess.run(
        ["wl-paste", "-p"], capture_output=True, text=True
    )
    return result.stdout.strip()


def query_dict(word, dict_name):
    try:
        sdcv = subprocess.Popen(
            ["sdcv", "-n", "--use-dict", dict_name, word],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        html = subprocess.Popen(
            ["html2text"] + HTML2TEXT_ARGS,
            stdin=sdcv.stdout,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        )
        sdcv.stdout.close()
        raw, _ = html.communicate()
        if not raw or not raw.strip():
            return None

        parser = subprocess.run(
            [sys.executable,
             os.path.join(SCRIPT_DIR, "parser-dic.py"),
             "--diccionario", dict_name],
            input=raw,
            capture_output=True,
            text=True,
        )
        out = parser.stdout.strip()
        return out if out else None
    except Exception:
        return None


def main():
    word = get_selection()
    # word = "learning"
    if not word:
        print("No text in primary selection.", file=sys.stderr)
        sys.exit(1)

    word = word.splitlines()[0].strip()
    if not word:
        print("Empty text.", file=sys.stderr)
        sys.exit(1)

    dicts = get_available_dicts()
    for d in dicts:
        print(f"\n── {d} ──")
        result = query_dict(word, d)
        if result:
            print(result)
        else:
            print("(no entries)")


if __name__ == "__main__":
    main()
