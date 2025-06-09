# Use Apple's official Swift Docker image for Linux
FROM swift:6.1-jammy

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files first for better caching
COPY Package.swift Package.resolved ./

# Copy source code
COPY Sources ./Sources
COPY Tests ./Tests

# Copy external dependencies (including submodules)
COPY external ./external

# Build the project
RUN swift build

# Run tests by default
CMD ["swift", "test"]