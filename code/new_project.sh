#!/usr/bin/env bash
# Scaffold a new project under ~/code with git + a direnv-managed flake devShell.
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <project-name>" >&2
    exit 1
fi

name="$1"
dir="$HOME/code/$name"

if [[ -e "$dir" ]]; then
    echo "Error: $dir already exists" >&2
    exit 1
fi

mkdir -p "$dir"
cd "$dir"

git init -q

cat > flake.nix <<EOF
{
  description = "$name";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.\${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ ];
        };
      });
    };
}
EOF

echo "use flake" > .envrc

cat > README.md <<EOF
# $name
EOF

cat > .gitignore <<'EOF'
# direnv
.direnv/

# nix build output
result
result-*

# build output
bin/
obj/
build/
dist/
out/
target/
node_modules/
__pycache__/
*.pyc
*.o
*.obj
*.class

# OS
.DS_Store

# editor
*.swp
.vscode/
.idea/
EOF

direnv allow

echo "Created $dir"
