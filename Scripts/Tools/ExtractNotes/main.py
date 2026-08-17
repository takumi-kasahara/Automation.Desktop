#!/usr/bin/env python3
"""
PowerPoint presentation notes extraction script.
Extracts notes from slides and saves to a text file.
"""

import argparse
import glob
import os
import re
from mimetypes import guess_type

from pptx import Presentation

POWERPOINT_MIME_TYPES = {
    "application/vnd.oasis.opendocument.presentation",
    "application/vnd.ms-powerpoint",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
}

__all__ = ["POWERPOINT_MIME_TYPES", "extract_notes_from_presentation"]

_SEQ_TEMPLATE_RE = re.compile(r"%0?\d*[diouxXeEfFgGcrs]")


def is_sequence_template(s: str) -> bool:
    """Check if the string contains a printf-style sequence template like %03d."""
    return _SEQ_TEMPLATE_RE.search(s) is not None


def build_split_paths(
    output_option: str, source_name: str, count: int, default_ext: str
) -> list[str]:
    """Build a list of output file paths with sequential numbering."""
    width = len(str(count))
    if is_sequence_template(output_option):
        return [output_option % (i + 1) for i in range(count)]

    # Treat as directory: create a subfolder named after the source file
    if os.path.isdir(output_option) or output_option in (".", ".."):
        base_name = os.path.splitext(os.path.basename(source_name))[0]
        target_dir = os.path.join(output_option, base_name)
    else:
        target_dir = output_option

    os.makedirs(target_dir, exist_ok=True)
    return [
        os.path.join(target_dir, f"{i + 1:0{width}d}{default_ext}")
        for i in range(count)
    ]


def clean(text: str) -> str:
    """
    Convert text to API-compatible format by replacing:
    - Ruby format {kanji|reading} -> kanji
    - Memo format [memo] -> (removed)
    """
    text = re.sub(r"[{｛]([^{|｜}｛｝]+)[|｜][^{}｛｝]+[}｝]", r"\1", text)
    text = re.sub(r"\[[^\[\]\［］]*\]|［[^\[\]\［］]*］", "", text)
    return text


def extract_notes_from_presentation(file_path: str) -> list[str]:
    """
    Extract text from PowerPoint notes slides.
    Returns a list of text lines from notes_text_frame.
    """
    presentation = Presentation(file_path)
    lines: list[str] = []
    for slide in presentation.slides:
        text = slide.notes_slide.notes_text_frame.text.strip()
        if text:
            lines.append(text)
    return lines


def main() -> None:
    """
    Extract notes from PowerPoint presentations and save to text files.
    Supports single files or glob patterns for batch processing.
    """
    parser = argparse.ArgumentParser(
        description="Extract notes from PowerPoint presentations"
    )
    parser.add_argument(
        "-i",
        "--input",
        type=str,
        required=True,
        help="Input PowerPoint file or glob pattern (pptx, odp, etc.)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        required=True,
        help="Output text file or directory if input is a pattern",
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="Force overwrite of output file if it exists",
    )
    parser.add_argument(
        "--split",
        action="store_true",
        help="Save each note as a separate file with sequential numbering",
    )
    args = parser.parse_args()

    input_pattern = args.input
    output_option = args.output

    files = glob.glob(input_pattern, recursive=True)
    is_pattern = "*" in input_pattern or "**" in input_pattern

    if not files:
        print(f"Error: No files matching pattern: {input_pattern}")
        return

    if is_pattern:
        # Multiple files matched, output must be a directory.
        if not os.path.isdir(output_option):
            print(
                "Error: When using wildcards for input, --output must be an existing directory."
            )
            return
    else:
        # Single file specified, if output is a directory (and not split mode), generate a file name automatically
        if not args.split and os.path.isdir(output_option):
            base_name = os.path.splitext(os.path.basename(input_pattern))[0]
            output_option = os.path.join(output_option, f"{base_name}.txt")
        elif (
            args.split
            and not os.path.isdir(output_option)
            and not is_sequence_template(output_option)
        ):
            print(
                "Error: When using --split, --output must be an existing directory or a template string like 'output_%03d.txt'."
            )
            return

    for input_file in files:
        if not os.path.exists(input_file):
            continue

        mime_type, _ = guess_type(input_file)
        if mime_type not in POWERPOINT_MIME_TYPES:
            print(
                f"Skipping unsupported file type: {input_file} ({mime_type or 'unknown'})"
            )
            continue

        if is_pattern:
            base_name = os.path.splitext(os.path.basename(input_file))[0]
            output_file = os.path.join(output_option, f"{base_name}.txt")
        else:
            output_file = output_option

        if (
            not args.split
            and os.path.exists(output_file)
            and not args.force
            and input(f"File {output_file} already exists. Overwrite? (y/N): ").lower()
            != "y"
        ):
            print(f"Skipping {input_file} (output file exists).")
            continue

        print(f"Extracting notes from: {input_file}")
        lines = extract_notes_from_presentation(input_file)

        if not lines:
            print(f"No notes found in {input_file}.")
            continue

        if args.split:
            paths = build_split_paths(output_option, input_file, len(lines), ".txt")
            for i, line in enumerate(lines):
                text = re.sub(r"\n+", "\n", clean(line)).strip() + "\n"
                out_path = paths[i]
                if (
                    os.path.exists(out_path)
                    and not args.force
                    and (
                        input(
                            f"File {out_path} already exists. Overwrite? (y/N): "
                        ).lower()
                        != "y"
                    )
                ):
                    print(f"Skipping {out_path} (file exists).")
                    continue
                with open(out_path, "w", encoding="utf-8") as f:
                    f.write(text)
            print(f"Successfully saved {len(lines)} notes to {paths[0]} etc.")
        else:
            text = f"{'\n\n'.join([re.sub(r'\n+', '\n', clean(line)).strip() for line in lines])}\n"
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(text)
            print(f"Successfully saved {len(lines)} notes to {output_file}")


if __name__ == "__main__":
    main()
