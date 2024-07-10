ARG BASE_IMAGE
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create and use the Python venv
WORKDIR /
RUN python3 -m venv --system-site-packages /venv

# Clone the git repo of stable-audio-tools and set version
ARG STABLE_AUDIO_TOOLS_COMMIT
RUN git clone https://github.com/Stability-AI/stable-audio-tools.git && \
    cd /stable-audio-tools && \
    git checkout ${STABLE_AUDIO_TOOLS_COMMIT}

# Install the dependencies for stable-audio-tools
ARG INDEX_URL
ARG TORCH_VERSION
ARG XFORMERS_VERSION
WORKDIR /stable-audio-tools
ENV TORCH_INDEX_URL=${INDEX_URL}
ENV TORCH_COMMAND="pip install torch==${TORCH_VERSION} torchvision --index-url ${TORCH_INDEX_URL}"
ENV XFORMERS_PACKAGE="xformers==${XFORMERS_VERSION}"
RUN source /venv/bin/activate && \
    ${TORCH_COMMAND} && \
    pip3 install ${XFORMERS_PACKAGE} --index-url ${TORCH_INDEX_URL} &&  \
    pip3 install . && \
    pip3 install flash_attn && \
    deactivate
RUN mkdir -p /stable-audio-tools/ckpt

# Add model
WORKDIR /stable-audio-tools/ckpt
ADD https://huggingface.co/ashleykleynhans/stable-audio-tools/resolve/main/model.safetensors model.safetensors
ADD https://huggingface.co/ashleykleynhans/stable-audio-tools/resolve/main/model_config.json model_config.json

# Remove existing SSH host keys
RUN rm -f /etc/ssh/ssh_host_*

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Set template version
ARG RELEASE
ENV TEMPLATE_VERSION=${RELEASE}

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]
