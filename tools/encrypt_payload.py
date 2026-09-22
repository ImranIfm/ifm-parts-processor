"""Encrypt the release zip so the published bytes are useless without the credentials.

GitHub Pages is static, so there is no server that could check a password before handing
over a file. Rather than pretend, the payload itself is AES-256-GCM encrypted under a key
derived from the credentials with PBKDF2-SHA256. A wrong password does not fail a check
that could be skipped in devtools -- it simply yields a key that decrypts nothing.

File layout, which index.html reads back: salt(16) | iv(12) | ciphertext+tag.

Credentials are read from the environment so they never appear in this file or in a
command line. publish-build.ps1 prompts for them and sets them for one process only.
"""

import os
import sys
import json
import hashlib

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

ITERATIONS = 600_000
SALT_LEN = 16
IV_LEN = 12


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: encrypt_payload.py <plaintext.zip> <payload.bin>", file=sys.stderr)
        return 2

    src, dst = sys.argv[1], sys.argv[2]
    user = os.environ.get("DL_USER")
    pwd = os.environ.get("DL_PASS")
    if not user or not pwd:
        print("DL_USER and DL_PASS must be set", file=sys.stderr)
        return 2

    salt = os.urandom(SALT_LEN)
    iv = os.urandom(IV_LEN)
    key = hashlib.pbkdf2_hmac("sha256", f"{user}:{pwd}".encode(), salt, ITERATIONS, 32)

    with open(src, "rb") as fh:
        data = fh.read()

    ciphertext = AESGCM(key).encrypt(iv, data, None)

    os.makedirs(os.path.dirname(os.path.abspath(dst)), exist_ok=True)
    with open(dst, "wb") as fh:
        fh.write(salt + iv + ciphertext)

    print(json.dumps({
        "plaintext_mb": round(len(data) / 1048576, 1),
        "encrypted_mb": round((SALT_LEN + IV_LEN + len(ciphertext)) / 1048576, 1),
        "plaintext_sha256": hashlib.sha256(data).hexdigest(),
        "iterations": ITERATIONS,
    }, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
