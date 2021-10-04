ARG ubuntu_version=focal
FROM ubuntu:${ubuntu_version}

ENV DEBIAN_FRONTEND noninteractive

# Install packages available from standard repos
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    software-properties-common wget git gpg-agent file \
    python3 python3-pip doxygen graphviz ninja-build make sudo ccache cppcheck \
    vim

# Install conan
RUN python3 -m pip install --upgrade pip setuptools && \
    python3 -m pip install conan && \
    conan --version

# User-settable versions:
# This Dockerfile should support gcc-[7, 8, 9, 10] and clang-[10, 11, 12]
# Earlier versions of clang will require significant modifications to the IWYU section
ARG gcc_version="10"
# Add gcc-${gcc_version}
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends gcc-${gcc_version} g++-${gcc_version}

ARG llvm_version="12"
# Add clang-${llvm_version}
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - 2>/dev/null && \
    add-apt-repository -y "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-${llvm_version} main" && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    clang-${llvm_version} lldb-${llvm_version} lld-${llvm_version} clangd-${llvm_version} \
    llvm-${llvm_version}-dev libclang-${llvm_version}-dev clang-tidy-${llvm_version}

# Add current cmake/ccmake, from Kitware
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null \
    | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main' && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends cmake cmake-curses-gui

# Set the default clang-tidy, so CMake can find it
RUN update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-${llvm_version}) 1

# Install include-what-you-use
ENV IWYU /home/iwyu
ENV IWYU_BUILD ${IWYU}/build
ENV IWYU_SRC ${IWYU}/include-what-you-use
RUN mkdir -p ${IWYU_BUILD} && \
    git clone --branch clang_${llvm_version} \
    https://github.com/include-what-you-use/include-what-you-use.git \
    ${IWYU_SRC}
RUN CC=clang-${llvm_version} CXX=clang++-${llvm_version} cmake -S ${IWYU_SRC} \
    -B ${IWYU_BUILD} \
    -G "Unix Makefiles" -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${llvm_version} && \
    cmake --build ${IWYU_BUILD} -j && \
    cmake --install ${IWYU_BUILD}

# Per https://github.com/include-what-you-use/include-what-you-use#how-to-install:
# `You need to copy the Clang include directory to the expected location before
#  running (similarly, use include-what-you-use -print-resource-dir to learn
#  exactly where IWYU wants the headers).`
RUN mkdir -p $(include-what-you-use -print-resource-dir 2>/dev/null)
RUN ln -s $(readlink -f /usr/lib/clang/${llvm_version}/include) \
    $(include-what-you-use -print-resource-dir 2>/dev/null)/include

## Cleanup cached apt data we don't need anymore
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set gcc-${gcc_version} as default gcc
RUN update-alternatives --install /usr/bin/gcc gcc $(which gcc-${gcc_version}) 100
RUN update-alternatives --install /usr/bin/g++ g++ $(which g++-${gcc_version}) 100

# Set clang-${llvm_version} as default clang
RUN update-alternatives --install /usr/bin/clang clang $(which clang-${llvm_version}) 100
RUN update-alternatives --install /usr/bin/clang++ clang++ $(which clang++-${llvm_version}) 100

# setup dev user
ARG user=dev
ARG group=dev
ARG uid=1000
ARG gid=1000
ARG home=/home/dev

RUN groupadd -g ${gid} ${group} && \
    useradd -d ${home} -u ${uid} -g ${gid} -m -s /bin/bash ${user} && \
    passwd -d ${user} && \
    echo "${user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudoers_${user}

USER ${user}
# Configure ccache
RUN mkdir ${home}/.ccache \
    && echo "max_size = 5.0G" > ${home}/.ccache/ccache.conf

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Allow the user to set compiler defaults
ARG use_clang
# if --build-arg use_clang=1, set CC to 'clang' or set to null otherwise.
ENV CC=${use_clang:+"clang"}
ENV CXX=${use_clang:+"clang++"}
# if CC is null, set it to 'gcc' (or leave as is otherwise).
ENV CC=${CC:-"gcc"}
ENV CXX=${CXX:-"g++"}

WORKDIR ${home}

VOLUME [ "${home}/work" ]

CMD ["/bin/bash"]
