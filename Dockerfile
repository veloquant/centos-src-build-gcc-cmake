ARG BASE_IMAGE=yitzikc/centos-cpp-eclipse-dev:centos-7.8-ec-2020-06

FROM $BASE_IMAGE

RUN yum install -y \
        gmp-devel mpfr-devel libmpc-devel libcurl libcurl-devel zlib-devel openssl-libs openssl-devel && \
    yum clean -y all

WORKDIR /usr/src

ARG GCC_VERSION=7.4.0

RUN wget -nv http://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
    tar zxf gcc-${GCC_VERSION}.tar.gz && \
    mkdir gcc-${GCC_VERSION}-build && \
    cd gcc-${GCC_VERSION}-build && \
    ../gcc-${GCC_VERSION}/configure --enable-languages=c,c++ --disable-multilib && \
    make -j$(nproc) && \
    cp `readlink -f x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6` /usr/local/lib64/ && \
    cp -l /usr/local/lib64/`readlink -f x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6 | xargs basename` /usr/lib64/ && \
    ln -sfr \
        /usr/lib64/`readlink -f x86_64-pc-linux-gnu/libstdc++-v3/src/.libs/libstdc++.so.6 | xargs basename` \
        /usr/lib64/libstdc++.so.6 && \
    make install && \
    gcc --version | grep -F " ${GCC_VERSION}" && \
    cd .. && \
    rm -rf gcc-${GCC_VERSION}.tar.gz gcc-${GCC_VERSION} gcc-${GCC_VERSION}-build

# Make the new GCC default
RUN mv /bin/gcc /bin/gcc-$(/bin/gcc -v  2>&1 | grep -oP 'version\s+\S+' | cut -d' ' -f2) && \
    ln -s /usr/local/bin/gcc /bin/gcc && \
    mv /bin/g++ /bin/g++-$(/bin/g++ -v  2>&1 | grep -oP 'version\s+\S+' | cut -d' ' -f2) && \
    ln -s /usr/local/bin/g++ /bin/g++ && \
    mv /usr/bin/gcc /usr/bin/gcc-$(/usr/bin/gcc -v 2>&1 | grep -oP 'version\s+\S+' | cut -d' ' -f2) && \
    ln -s /usr/local/bin/gcc /usr/bin/gcc && \
    mv /usr/bin/g++ /usr/bin/g++-$(/usr/bin/g++ -v 2>&1 | grep -oP 'version\s+\S+' | cut -d' ' -f2) && \
    ln -s /usr/local/bin/g++ /usr/bin/g++ && \
    ln -sfr /bin/g++ /bin/c++

ARG CMAKE_VERSION=3.14.2

RUN wget -nv -c https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz && \
    tar xvf cmake-${CMAKE_VERSION}.tar.gz && \
    cd cmake-${CMAKE_VERSION}/ && \
    ./bootstrap --system-curl && \
    gmake -j$(nproc) && \
    gmake install && \
    ln -sf /usr/local/bin/cmake /usr/bin/ && \
    cmake --version | grep -F " ${CMAKE_VERSION}" && \
    cd .. && \
    rm -rf cmake-${CMAKE_VERSION}.tar.gz cmake-${CMAKE_VERSION}

LABEL org.gnu.gcc.version $GCC_VERSION
LABEL org.cmake.version $CMAKE_VERSION

WORKDIR /root
