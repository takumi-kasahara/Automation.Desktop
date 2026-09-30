#!/usr/bin/env python3
"""
Test suite for tts.py
"""

import importlib.util
import io
import sys
import tempfile
import types
import wave
import zipfile
from collections.abc import Iterator
from pathlib import Path
from typing import Any

import pytest


class TestTTS:
    """
    Test cases for tts.py
    """

    @pytest.fixture
    def script_path(self) -> Path:
        """
        Return the path to the tts.py script.
        """
        return Path(__file__).parent.parent / "src" / "tts.py"

    @pytest.fixture
    def fake_extract_notes(self, monkeypatch: pytest.MonkeyPatch) -> types.ModuleType:
        """
        Provide a fake extract_notes module so tts.py can be imported without pptx.
        """
        module = types.ModuleType("extract_notes")
        module.__dict__["POWERPOINT_MIME_TYPES"] = {
            "application/vnd.ms-powerpoint",
            "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            "application/vnd.oasis.opendocument.presentation",
        }

        def is_sequence_template(value: str) -> bool:
            return "%" in value

        def build_split_paths(
            output_option: str, source_name: str, count: int, default_ext: str
        ) -> list[str]:
            if is_sequence_template(output_option):
                return [output_option % (i + 1) for i in range(count)]

            output_path = Path(output_option)
            if output_path.is_dir() or output_option in {".", ".."}:
                target_dir = output_path / Path(source_name).stem
            else:
                target_dir = output_path

            target_dir.mkdir(parents=True, exist_ok=True)
            width = len(str(count))
            return [
                str(target_dir / f"{i + 1:0{width}d}{default_ext}")
                for i in range(count)
            ]

        def extract_notes_from_presentation(file_path: str) -> list[str]:
            return [f"notes from {Path(file_path).name}"]

        module.__dict__["is_sequence_template"] = is_sequence_template
        module.__dict__["build_split_paths"] = build_split_paths
        module.__dict__["extract_notes_from_presentation"] = (
            extract_notes_from_presentation
        )

        monkeypatch.setitem(sys.modules, "extract_notes", module)
        return module

    @pytest.fixture
    def tts_module(self, fake_extract_notes: types.ModuleType, script_path: Path):
        """
        Import tts.py with the fake extract_notes module already registered.
        """
        module_name = "tts_under_test"
        sys.modules.pop(module_name, None)
        spec = importlib.util.spec_from_file_location(module_name, script_path)
        assert spec is not None and spec.loader is not None
        module = importlib.util.module_from_spec(spec)
        sys.modules[module_name] = module
        spec.loader.exec_module(module)
        return module

    @pytest.fixture
    def sample_text_file(self) -> Iterator[Path]:
        """
        Create a sample text file for testing.
        """
        with tempfile.NamedTemporaryFile(
            mode="w", suffix=".txt", delete=False, encoding="utf-8"
        ) as f:
            f.write("こんにちは。{漢字|かんじ}と[memo]のテスト。最後の文。")
            temp_path = Path(f.name)

        yield temp_path
        if temp_path.exists():
            temp_path.unlink()

    @pytest.fixture
    def sample_wav_bytes(self) -> bytes:
        """
        Create a tiny valid WAV payload for the fake VOICEVOX responses.
        """
        with io.BytesIO() as buffer:
            with wave.open(buffer, "wb") as wav_file:
                wav_file.setnchannels(1)
                wav_file.setsampwidth(2)
                wav_file.setframerate(24000)
                wav_file.writeframes(b"\x00\x00" * 24)
            return buffer.getvalue()

    @pytest.fixture
    def mock_voicevox(self, monkeypatch: pytest.MonkeyPatch, sample_wav_bytes: bytes):
        """
        Mock the VOICEVOX HTTP API used by tts.py.
        """

        class Response:
            """
            Mock HTTP response for VOICEVOX API.
            """

            def __init__(self, *, json_data=None, content=b"", status_code=200):
                self._json_data = json_data
                self.content = content
                self.status_code = status_code

            def raise_for_status(self) -> None:
                """
                Raise an exception if the HTTP status code indicates an error (HTTP 4xx or 5xx).
                """
                if self.status_code >= 400:
                    raise RuntimeError(f"HTTP {self.status_code}")

            def json(self) -> Any:
                """
                Return the JSON data from the response.
                """
                return self._json_data

        speakers = [{"name": "Speaker A", "styles": [{"id": 1, "name": "Normal"}]}]

        def fake_get(url, **_kwargs):
            assert url.endswith("/speakers")
            return Response(json_data=speakers)

        def fake_post(url, params=None, json=None, **_kwargs):
            if url.endswith("/audio_query"):
                assert params is not None
                assert "text" in params
                assert "speaker" in params
                return Response(
                    json_data={"text": params["text"], "speaker": params["speaker"]}
                )

            assert url.endswith("/multi_synthesis")
            assert isinstance(json, list)
            with io.BytesIO() as buffer:
                with zipfile.ZipFile(
                    buffer, mode="w", compression=zipfile.ZIP_DEFLATED
                ) as archive:
                    for index, _query in enumerate(json, start=1):
                        archive.writestr(f"{index:03d}.wav", sample_wav_bytes)
                return Response(content=buffer.getvalue())

        monkeypatch.setattr("requests.get", fake_get)
        monkeypatch.setattr("requests.post", fake_post)

    def test_clean_removes_ruby_and_memo(self, tts_module) -> None:
        """
        The clean helper should normalize VOICEVOX input text.
        """
        assert tts_module.clean("{漢字|かんじ}と[memo]です") == "かんじとです"
        assert tts_module.clean("｛漢字｜かんじ｝と［memo］です") == "かんじとです"

    def test_generate_voice_uses_mocked_api(self, tts_module, mock_voicevox) -> None:
        """
        generate_voice should call the mocked VOICEVOX endpoint and enrich the query.
        """
        query = tts_module.generate_voice(tts_module.DEFAULT_URL, "こんにちは", 1)
        assert query["text"] == "こんにちは"
        assert query["speaker"] == 1
        assert query["prePhonemeLength"] == 0.25
        assert query["postPhonemeLength"] == 0.25

    def test_multi_synthesis_individual_returns_wav_chunks(
        self, tts_module, mock_voicevox, sample_wav_bytes: bytes
    ) -> None:
        """
        multi_synthesis_individual should unpack the mocked ZIP response into WAV chunks.
        """
        queries = [{"text": "a"}, {"text": "b"}]
        wav_list = tts_module.multi_synthesis_individual(
            tts_module.DEFAULT_URL, queries, 1
        )
        assert len(wav_list) == 2
        assert wav_list[0] == sample_wav_bytes
        assert wav_list[1] == sample_wav_bytes

    def test_multi_synthesis_combines_wav_chunks(
        self, tts_module, mock_voicevox
    ) -> None:
        """
        multi_synthesis should combine the mocked WAV chunks into one output file.
        """
        audio_data = tts_module.multi_synthesis(
            tts_module.DEFAULT_URL, [{"text": "a"}, {"text": "b"}], 1
        )
        with wave.open(io.BytesIO(audio_data), "rb") as wav_file:
            assert wav_file.getnframes() > 0
            assert wav_file.getframerate() == 24000

    def test_select_speaker_with_mocked_api(self, tts_module, mock_voicevox) -> None:
        """
        select_speaker should return the provided speaker id after consulting the mocked API.
        """
        assert tts_module.select_speaker(tts_module.DEFAULT_URL, 1) == 1

    def test_main_creates_single_output_file_with_mocked_voicevox(
        self,
        tts_module,
        mock_voicevox,
        sample_text_file: Path,
        monkeypatch: pytest.MonkeyPatch,
    ) -> None:
        """
        main should create a single WAV file without calling the real VOICEVOX API.
        """
        with tempfile.TemporaryDirectory() as tmpdir:
            output_dir = Path(tmpdir)
            monkeypatch.setattr(
                sys,
                "argv",
                [
                    "tts.py",
                    "-i",
                    str(sample_text_file),
                    "-o",
                    str(output_dir),
                    "-s",
                    "1",
                ],
            )

            tts_module.main()

            output_file = output_dir / f"{sample_text_file.stem}.wav"
            assert output_file.exists()
            assert output_file.stat().st_size > 44

    def test_main_creates_split_outputs_with_mocked_voicevox(
        self,
        tts_module,
        mock_voicevox,
        sample_text_file: Path,
        monkeypatch: pytest.MonkeyPatch,
    ) -> None:
        """
        main should create split WAV files using the mocked VOICEVOX API.
        """
        with tempfile.TemporaryDirectory() as tmpdir:
            output_dir = Path(tmpdir) / "split"
            output_dir.mkdir()
            monkeypatch.setattr(
                sys,
                "argv",
                [
                    "tts.py",
                    "-i",
                    str(sample_text_file),
                    "-o",
                    str(output_dir),
                    "-s",
                    "1",
                    "--split",
                ],
            )

            tts_module.main()

            split_dir = output_dir / sample_text_file.stem
            audio_files = sorted(split_dir.glob("*.wav"))
            assert len(audio_files) == 3
            assert [path.name for path in audio_files] == ["1.wav", "2.wav", "3.wav"]

    def test_main_skips_when_input_file_is_missing(
        self, tts_module, mock_voicevox, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """
        main should exit cleanly when glob finds no matching files.
        """
        with tempfile.TemporaryDirectory() as tmpdir:
            output_dir = Path(tmpdir)
            missing_file = output_dir / "missing.txt"
            monkeypatch.setattr(
                sys,
                "argv",
                [
                    "tts.py",
                    "-i",
                    str(missing_file),
                    "-o",
                    str(output_dir),
                    "-s",
                    "1",
                ],
            )

            tts_module.main()

            assert not list(output_dir.glob("**/*.wav"))
