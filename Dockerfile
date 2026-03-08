FROM ubuntu:22.04

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip

# Install HyperonPy
RUN pip3 install hyperon

# Set working directory
WORKDIR /app

# Copy your code and MeTTa f# Use Ubuntu
FROM ubuntu:22.04

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip

# Install HyperonPy
RUN pip3 install hyperon

# Set working directory
WORKDIR /app

# Copy your code and MeTTa file
COPY . .

# Run the Python script
CMD ["python3", "run_metta.py"]

