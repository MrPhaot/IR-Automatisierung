"""Small, dependency-free reader for the NBT subset used by Minecraft 1.7.10.

The reader intentionally returns ordinary Python values. Compound tags become
dicts, lists become lists, byte arrays become bytes, and strings/numbers retain
their natural Python representation. It is read-only and has no Minecraft
runtime dependency.
"""

from __future__ import annotations

import io
import struct
from typing import Any


class NBTError(ValueError):
    """Raised when an NBT stream is malformed or exceeds safety limits."""


TAG_END = 0
TAG_BYTE = 1
TAG_SHORT = 2
TAG_INT = 3
TAG_LONG = 4
TAG_FLOAT = 5
TAG_DOUBLE = 6
TAG_BYTE_ARRAY = 7
TAG_STRING = 8
TAG_LIST = 9
TAG_COMPOUND = 10
TAG_INT_ARRAY = 11
TAG_LONG_ARRAY = 12


class NBTReader:
    def __init__(self, data: bytes, *, max_depth: int = 128, max_items: int = 2_000_000):
        self._stream = io.BytesIO(data)
        self.max_depth = max_depth
        self.max_items = max_items
        self._items = 0

    def _read(self, size: int) -> bytes:
        value = self._stream.read(size)
        if len(value) != size:
            raise NBTError(f"unexpected end of NBT stream while reading {size} bytes")
        return value

    def _unpack(self, fmt: str) -> Any:
        return struct.unpack(fmt, self._read(struct.calcsize(fmt)))[0]

    def _u8(self) -> int:
        return self._unpack(">B")

    def _i32(self) -> int:
        return self._unpack(">i")

    def _string(self) -> str:
        size = self._unpack(">H")
        try:
            return self._read(size).decode("utf-8")
        except UnicodeDecodeError as exc:
            raise NBTError("invalid UTF-8 in NBT string") from exc

    def read_root(self) -> tuple[str, Any]:
        tag_type = self._u8()
        if tag_type == TAG_END:
            raise NBTError("root NBT tag cannot be TAG_End")
        return self._string(), self._payload(tag_type, 0)

    def _payload(self, tag_type: int, depth: int) -> Any:
        if depth > self.max_depth:
            raise NBTError("NBT nesting depth exceeds safety limit")
        if tag_type == TAG_BYTE:
            return self._unpack(">b")
        if tag_type == TAG_SHORT:
            return self._unpack(">h")
        if tag_type == TAG_INT:
            return self._unpack(">i")
        if tag_type == TAG_LONG:
            return self._unpack(">q")
        if tag_type == TAG_FLOAT:
            return self._unpack(">f")
        if tag_type == TAG_DOUBLE:
            return self._unpack(">d")
        if tag_type == TAG_BYTE_ARRAY:
            return self._read_array(1)
        if tag_type == TAG_STRING:
            return self._string()
        if tag_type == TAG_LIST:
            item_type = self._u8()
            count = self._i32()
            if count < 0 or count > self.max_items:
                raise NBTError(f"invalid NBT list length: {count}")
            return [self._payload(item_type, depth + 1) for _ in range(count)]
        if tag_type == TAG_COMPOUND:
            result: dict[str, Any] = {}
            while True:
                item_type = self._u8()
                if item_type == TAG_END:
                    return result
                name = self._string()
                self._items += 1
                if self._items > self.max_items:
                    raise NBTError("NBT item count exceeds safety limit")
                result[name] = self._payload(item_type, depth + 1)
        if tag_type == TAG_INT_ARRAY:
            return self._read_array(4)
        if tag_type == TAG_LONG_ARRAY:
            return self._read_array(8)
        raise NBTError(f"unsupported NBT tag type: {tag_type}")

    def _read_array(self, element_size: int) -> list[int] | bytes:
        count = self._i32()
        if count < 0 or count > self.max_items:
            raise NBTError(f"invalid NBT array length: {count}")
        if element_size == 1:
            return self._read(count)
        fmt = ">" + ("i" if element_size == 4 else "q")
        return [self._unpack(fmt) for _ in range(count)]


def parse_nbt(data: bytes) -> tuple[str, Any]:
    return NBTReader(data).read_root()


def json_safe(value: Any) -> Any:
    """Convert NBT values to deterministic JSON-compatible values."""

    if isinstance(value, bytes):
        return {"__bytes_hex__": value.hex()}
    if isinstance(value, dict):
        return {str(key): json_safe(item) for key, item in sorted(value.items())}
    if isinstance(value, list):
        return [json_safe(item) for item in value]
    return value
