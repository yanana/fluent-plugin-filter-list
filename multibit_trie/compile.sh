# Following targets are not supported by cross.
# - i686-apple-darwin
# - x86_64-apple-darwin
# - i686-pc-windows-msvc
# - x86_64-pc-windows-msvc

# Building dynamic library for the container's triple.
cargo build --release

if [ "$TRAVIS_OS_NAME" = "linux" ]; then
    cross build --release --target x86_64-unknown-linux-gnu
    cross build --release --target i686-unknown-linux-gnu
    cross build --release --target i686-pc-windows-gnu
    cross build --release --target x86_64-pc-windows-gnu
elif [ "$TRAVIS_OS_NAME" = "osx" ]; then
    cross build --release --target x86_64-apple-darwin    
fi
