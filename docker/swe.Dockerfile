FROM ubuntu:jammy

ARG TARGETARCH

# Install third party tools and dependencies
RUN apt-get update && \
    apt-get install -y bash gcc git jq wget g++ make apt-transport-https \
    ca-certificates gnupg software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Initialize git
RUN git config --global user.email "sweagent@pnlp.org"
RUN git config --global user.name "sweagent"

# Environment variables
ENV ROOT='/dev/'
RUN prompt() { echo " > "; };
ENV PS1="> "

# Create file for tracking edits, test patch
RUN touch /root/files_to_edit.txt
RUN touch /root/test.patch

# add ls file indicator
RUN echo "alias ls='ls -F'" >> /root/.bashrc

# Install Miniconda
ENV PATH="/root/miniconda3/bin:${PATH}"
COPY docker/getconda.sh .
RUN bash getconda.sh ${TARGETARCH} \
    && rm getconda.sh \
    && mkdir /root/.conda \
    && bash miniconda.sh -b \
    && rm -f miniconda.sh
RUN conda --version \
    && conda init bash \
    && conda config --append channels conda-forge

# Install python packages
COPY docker/requirements.txt /root/requirements.txt
RUN /root/miniconda3/bin/pip install -r /root/requirements.txt

# Install .NET SDK
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-6.0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

CMD ["/bin/bash"]
