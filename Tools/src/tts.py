#!/usr/bin/env python3
"""
A text-to-speech script using [VOICEVOX](https://voicevox.hiroshiba.jp/).
"""

import argparse
import glob
import io
import os
import re
import wave
import zipfile
from mimetypes import guess_type
from typing import Any

import requests

from extract_notes import (
    POWERPOINT_MIME_TYPES,
    build_split_paths,
    extract_notes_from_presentation,
    is_sequence_template,
)

DEFAULT_URL = "http://localhost:50021"


def clean(text: str) -> str:
    """
    Convert text to API-compatible format by replacing:
    - Ruby format {kanji|reading} -> reading
    - Memo format [memo] -> (removed)
    """
    text = re.sub(r"[{｛][^{|｜}｛｝]+[|｜]([^{}｛｝]+)[}｝]", r"\1", text)
    text = re.sub(r"\[[^\[\]\［］]*\]|［[^\[\]\［］]*］", "", text)
    return text


def generate_voice(url: str, text: str, speaker_id: int) -> dict[str, Any]:
    """
    Create a speech synthesis query using /audio_query endpoint.
    """
    response = requests.post(
        f"{url}/audio_query",
        params={"text": text, "speaker": speaker_id},
        timeout=10,
    )
    response.raise_for_status()
    json = response.json()
    json["prePhonemeLength"] = 0.25
    json["postPhonemeLength"] = 0.25
    return json


def multi_synthesis_individual(
    url: str, queries: list[dict[str, Any]], speaker_id: int
) -> list[bytes]:
    """
    Synthesize multiple queries at once using /multi_synthesis endpoint.
    Returns a list of individual WAV data bytes.
    """
    response = requests.post(
        f"{url}/multi_synthesis",
        params={"speaker": speaker_id},
        json=queries,  # type: ignore[arg-type]
        timeout=10 * len(queries),
    )
    response.raise_for_status()

    with zipfile.ZipFile(io.BytesIO(response.content)) as z:
        wav_files = sorted([f for f in z.namelist() if f.endswith(".wav")])
        if not wav_files:
            raise RuntimeError("No WAV files found in the synthesis zip.")
        return [z.read(f) for f in wav_files]


def multi_synthesis(url: str, queries: list[dict[str, Any]], speaker_id: int) -> bytes:
    """
    Synthesize multiple queries at once using /multi_synthesis endpoint and return combined WAV.
    """
    wav_list = multi_synthesis_individual(url, queries, speaker_id)
    if not wav_list:
        raise RuntimeError("No WAV data returned.")

    with wave.open(io.BytesIO(wav_list[0]), "rb") as first_wav:
        params = first_wav.getparams()
        all_frames = first_wav.readframes(first_wav.getnframes())

    for wav_data in wav_list[1:]:
        with wave.open(io.BytesIO(wav_data), "rb") as wav:
            all_frames += wav.readframes(wav.getnframes())

    with io.BytesIO() as output_buffer:
        with wave.open(output_buffer, "wb") as output_wav:  # type: ignore[attr-defined]
            output_wav.setparams(params)
            output_wav.writeframes(all_frames)
        return output_buffer.getvalue()


def select_speaker(url: str, speaker_id: int | None = None) -> int:
    """
    Fetch speaker list from API and prompt user to select one.
    If speaker_id is provided, display the speaker name and return it without prompting.
    """
    print(f"Fetching speaker list from {url}...")
    response = requests.get(f"{url}/speakers", timeout=10)
    response.raise_for_status()
    speakers = response.json()
    speakers_ids = {
        style["id"]: f"{s['name']} ({style['name']})"
        for s in speakers
        for style in s.get("styles", [])
    }
    if speaker_id is not None:
        print(f"Selected Speaker: {speakers_ids.get(speaker_id, 'Unknown')}")
        return speaker_id

    print("\n--- Available Speakers ---")
    for s in speakers:
        name = s.get("name", "Unknown")
        print(f"\nid:\t{name}")
        for style in s.get("styles", []):
            print(f"\tid:\t{style['id']}\tname:\t{style['name']}")

    while True:
        try:
            choice = input("\nSelect Speaker ID: ")
            print(f"Selected Speaker: {speakers_ids.get(int(choice), 'Unknown')}")
            return int(choice)
        except ValueError:
            print("Please enter a valid integer ID.")


def main() -> None:
    """
    Main entry point for the text-to-speech script.
    Processes text or PowerPoint files (including glob patterns) and generates voice audio using VOICEVOX.
    """
    parser = argparse.ArgumentParser(description="VOICEVOX text-to-speech script")
    parser.add_argument(
        "-i",
        "--input",
        type=str,
        required=True,
        help="Input text or PowerPoint file or glob pattern (pptx, odp, etc.)",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=str,
        required=True,
        help="Output wav file or directory if input is a pattern",
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="Force overwrite of output file if it exists",
    )
    parser.add_argument(
        "-u",
        "--url",
        type=str,
        default=DEFAULT_URL,
        help=f"VOICEVOX API URL (default: {DEFAULT_URL})",
    )
    parser.add_argument("-s", "--speaker", type=int, help="Speaker ID")
    parser.add_argument(
        "--split",
        action="store_true",
        help="Save each slide as a separate file with sequential numbering",
    )
    args = parser.parse_args()

    input_pattern = args.input
    output_option = args.output
    url = args.url
    speaker_id = select_speaker(url, args.speaker)

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
        # Single file specified
        if not args.split and os.path.isdir(output_option):
            # Generate output file name automatically (maintain existing behavior)
            base_name = os.path.splitext(os.path.basename(input_pattern))[0]
            output_option = os.path.join(output_option, f"{base_name}.wav")
        elif (
            args.split
            and not os.path.isdir(output_option)
            and not is_sequence_template(output_option)
        ):
            print(
                "Error: When using --split, --output must be an existing directory or a template string like 'output_%03d.wav'."
            )
            return

    for input_file in files:
        if not os.path.exists(input_file):
            continue

        if is_pattern:
            base_name = os.path.splitext(os.path.basename(input_file))[0]
            output_file = os.path.join(output_option, f"{base_name}.wav")
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

        mime_type, _ = guess_type(input_file)
        if mime_type in POWERPOINT_MIME_TYPES:
            lines = extract_notes_from_presentation(input_file)
        elif mime_type and mime_type.startswith("text/"):
            with open(input_file, "r", encoding="utf-8") as f:
                text = f.read().strip()
            lines = [line.strip() for line in text.splitlines() if line.strip()]
        else:
            print(
                f"Error: Unsupported file type: {mime_type or 'unknown'} for {input_file}"
            )
            continue

        if not lines:
            print(f"Error: No text found in input file: {input_file}")
            continue

        print(f"Generating voice for: {input_file}")

        try:
            lines = [
                part.strip()
                for line in lines
                if line.strip()
                for part in line.split("。")
                if part.strip()
            ]
            queries: list[dict[str, Any]] = []
            for i, line in enumerate(lines):
                cleaned_line = clean(line)
                print(f"Creating query {i + 1}/{len(lines)}: {cleaned_line[:20]}...")
                queries.append(generate_voice(url, cleaned_line, speaker_id))
            print(f"Performing multi-synthesis for {len(queries)} chunks...")

            if args.split:
                audio_list = multi_synthesis_individual(url, queries, speaker_id)
                paths = build_split_paths(
                    output_file, input_file, len(audio_list), ".wav"
                )
                for i, data in enumerate(audio_list):
                    out_path = paths[i]
                    if (
                        os.path.exists(out_path)
                        and not args.force
                        and input(
                            f"File {out_path} already exists. Overwrite? (y/N): "
                        ).lower()
                        != "y"
                    ):
                        print(f"Skipping {out_path} (file exists).")
                        continue
                    with open(out_path, "wb") as f:
                        f.write(data)
                print(f"Successfully saved to {paths[0]} etc.")
            else:
                audio_data = multi_synthesis(url, queries, speaker_id)
                with open(output_file, "wb") as f:
                    f.write(audio_data)
                print(f"Successfully saved to {output_file}")
        except requests.exceptions.RequestException as e:
            print(f"API request failed for {input_file}: {e}")
        except OSError as e:
            print(f"File operation failed for {input_file}: {e}")
        except (RuntimeError, zipfile.BadZipFile, wave.Error) as e:
            print(f"Audio processing failed for {input_file}: {e}")


if __name__ == "__main__":
    main()
