FROM fedora:40 as base
RUN dnf install -y \
    cmake-3.27.7 \
    clang-17.0.6 \
    gcc-14.0.1 \
    gcc-c++-14.0.1 \
    libtsan \
    mold-2.4.0 \
    ninja-build-1.11.1 \
    curl \
    tar \
    && \
    yum clean all -y

# Only way around the error - build with fsanitize=thread
#ARG CMAKE_FLAGS="-G Ninja -DBUILD_TESTING=OFF -DCMAKE_CXX_FLAGS=-fsanitize=thread"
# Or build with clang??
ARG CMAKE_FLAGS="-G Ninja -DBUILD_TESTING=OFF -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
# Issue present when building with these flags:
#ARG CMAKE_FLAGS="-G Ninja -DBUILD_TESTING=OFF"
#ARG CMAKE_FLAGS="-G Ninja -DBUILD_TESTING=OFF -DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold"
#ARG CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Debug -G Ninja -DBUILD_TESTING=OFF -DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold"
#ARG CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release -G Ninja -DBUILD_TESTING=OFF -DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold"
#ARG CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=RelWithDebInfo -G Ninja -DBUILD_TESTING=OFF -DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=mold -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=mold"

RUN curl -o abseil.tar.gz -L https://github.com/abseil/abseil-cpp/archive/refs/tags/20230802.0.tar.gz && \
    # Note: v24.2 also tested, same issue
    curl -o protobuf.tar.gz -L https://github.com/protocolbuffers/protobuf/releases/download/v25.2/protobuf-25.2.tar.gz
RUN tar xzf abseil.tar.gz && \
    rm abseil.tar.gz && \
    mv abseil-cpp-20230802.0 abseil && \
    mkdir /abseil/build && \
    tar xzf protobuf.tar.gz && \
    rm protobuf.tar.gz && \
    mv protobuf-25.2 protobuf && \
    mkdir /protobuf/build
# Note: issue also present when statically linking
RUN cmake -S /abseil -B /abseil/build ${CMAKE_FLAGS} -DBUILD_SHARED_LIBS=ON && \
    cmake --build /abseil/build -j "$(nproc)" && \
    cmake --build /abseil/build --target install
RUN cmake -S /protobuf -B /protobuf/build ${CMAKE_FLAGS} -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_ABSL_PROVIDER=package -DBUILD_SHARED_LIBS=ON && \
    cmake --build /protobuf/build -j "$(nproc)"
RUN cmake --build /abseil/build --target install
RUN cmake --build /protobuf/build --target install
