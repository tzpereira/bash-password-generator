# Bash Password Generator

Minimal, secure password generator in pure Bash.
Works on **macOS** and **Linux**. Uses `/dev/urandom` for entropy.

---

## Features

- Password length: **12–48 characters**
- Security profiles:
  - `low`: lowercase only
  - `medium`: alphanumeric
  - `high`: alphanumeric + symbols
  - `ultra`: extended symbols
- Copy to clipboard (`pbcopy` / `xclip`)
- Interactive mode
- Zero dependencies

---

## Installation

```sh
chmod +x password-gen.sh
sudo cp password-gen.sh /usr/local/bin/passgen
```

---

## Usage

```sh
# Generate default password (16 characters, high profile)
passgen

# Set length and profile
passgen -l 20 -p ultra

# Copy to clipboard
passgen -c

# Interactive mode
passgen -i
```

## Uninstall

```sh
sudo rm /usr/local/bin/passgen
```

---

## License

This project is licensed under the MIT License — see the `LICENSE` file for details.
