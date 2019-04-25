# Following targets are not supported by cross.
# - i686-apple-darwin
# - i686-pc-windows-msvc
# - x86_64-apple-darwin

# Supported, but not work well...
# - i686-unknown-linux-gnu

cross build --release --target i686-pc-windows-gnu
cross build --release --target x86_64-pc-windows-gnu
cross build --release --target x86_64-pc-windows-msvc
cross build --release --target x86_64-unknown-linux-gnu
