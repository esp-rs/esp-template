# Note: gitpod/workspace-base image references older version of CMake, it's necessary to install newer one
FROM  gitpod/workspace-base
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# ARGS
ARG CONTAINER_USER=gitpod
ARG CONTAINER_GROUP=gitpod
ARG ESP_BOARD={{ mcu }}

# Install dependencies
RUN sudo install-packages git curl gcc ninja-build libudev-dev libpython2.7 \
    python3 python3-pip python3-venv libusb-1.0-0 libssl-dev pkg-config clang

# Set User
USER ${CONTAINER_USER}
WORKDIR /home/${CONTAINER_USER}

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    --default-toolchain none -y --profile minimal

# Update envs
ENV PATH=${PATH}:/home/${CONTAINER_USER}/.cargo/bin

# Install extra crates
RUN ARCH=$($HOME/.cargo/bin/rustup show | grep "Default host" | sed -e 's/.* //') && \
    curl -L "https://github.com/esp-rs/espup/releases/latest/download/espup-${ARCH}" -o "${HOME}/.cargo/bin/espup" && \
    chmod u+x "${HOME}/.cargo/bin/espup" && \
    curl -L "https://github.com/esp-rs/espflash/releases/latest/download/cargo-espflash-${ARCH}.zip" -o "${HOME}/.cargo/bin/cargo-espflash.zip" && \
    unzip "${HOME}/.cargo/bin/cargo-espflash.zip" -d "${HOME}/.cargo/bin/" && \
    rm "${HOME}/.cargo/bin/cargo-espflash.zip" && \
    chmod u+x "${HOME}/.cargo/bin/cargo-espflash" && \
    curl -L "https://github.com/bjoernQ/esp-web-flash-server/releases/latest/download/web-flash-${ARCH}.zip" -o "${HOME}/.cargo/bin/web-flash.zip" && \
    unzip "${HOME}/.cargo/bin/web-flash.zip" -d "${HOME}/.cargo/bin/" && \
    rm "${HOME}/.cargo/bin/web-flash.zip" && \
    chmod u+x "${HOME}/.cargo/bin/web-flash" && \
    curl -L "https://github.com/MabezDev/wokwi-server/releases/latest/download/wokwi-server-${ARCH}.zip" -o "${HOME}/.cargo/bin/wokwi-server.zip" && \
    unzip "${HOME}/.cargo/bin/wokwi-server.zip" -d "${HOME}/.cargo/bin/" && \
    rm "${HOME}/.cargo/bin/wokwi-server.zip" && \
    chmod u+x "${HOME}/.cargo/bin/wokwi-server"

# Install Xtensa Rust
RUN if [ -n "${GITHUB_TOKEN}" ]; then export GITHUB_TOKEN=${GITHUB_TOKEN}; fi  \
    && ${HOME}/.cargo/bin/espup install\
    --targets "${ESP_BOARD}" \
    --log-level debug \
    --export-file /home/${CONTAINER_USER}/export-esp.sh

# Set default toolchain
RUN if [ "${ESP_BOARD}" = "all" ] || echo "$ESP_BOARD" | grep -q "esp32c"; then \
    rustup default nightly; \
    else \
    rustup default esp; \
    fi

# Activate ESP environment
RUN echo "source /home/${CONTAINER_USER}/export-esp.sh" >> ~/.bashrc

CMD [ "/bin/bash" ]
